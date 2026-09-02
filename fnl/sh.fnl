; what do i want?
; i want to have some dsl over vim.system
; so i definetely want some piping
; and i want to inject info programmatically
; also i want to be able to run asyncronously
; okay so let's use vim.uv

(local uv vim.uv)

(macro dbg [arg]
  `(do 
    (print ,arg)
    ,arg))

(fn run [specs]
  (fn close-and-set [pipe] 
    (when (and pipe (not pipe.closed))
      (pipe.handle:close)
      (set pipe.closed true)))

  (local res {:finished false
              :procs []
              :pipes []
              :files []
              :wait (fn [self]
                      (each [i proc (ipairs self.procs)]
                        (vim.print (.. :proc i))
                        (vim.wait 1_000_000_000 #proc.closed))
                      (each [i pipe (ipairs self.pipes)]
                        (vim.print (.. :pipe i))
                        (vim.wait 1_000_000_000 #pipe.closed))
                      (vim.print :finished)
                      (vim.wait 1_000_000_000 #self.finished)
                      self.out)
              :ready (fn [self] self.finished)
              :cancel (fn [self]
                        (each [_ proc (ipairs self.procs)]
                          (close-and-set proc))
                        (each [_ pipe (ipairs self.pipes)]
                          (close-and-set pipe)))})
                          
  ; if pipe is nil, we call on-exit without args (which is ok, since lua doesn't enforce arguments
  (fn read-whole [pipe on-exit]
    (if pipe
      (do
        (local out [])
        (uv.read_start pipe.handle
          (fn [err data]
            (assert (not err) err)
            (if data
                (table.insert out data)
                (do 
                  (on-exit (table.concat out "")) 
                  (close-and-set pipe))))))
      (on-exit))) 

  (fn read-data [pipe on-data on-exit]
    (if pipe
      (uv.read_start pipe.handle
       (fn [err data]
         (vim.print "another one")
         (assert (not err) err)
         (if data
             (do
               (vim.print "getting data")
               (on-data data)
               (vim.print "got data"))
             (do
               (vim.print "closing pipe")
               (when on-exit (on-exit))
               (close-and-set pipe)))))
      (on-data))) 

  (fn create-pipe [] 
    (table.insert res.pipes {:handle (uv.new_pipe) :closed false})
    (. res.pipes (length res.pipes)))

  (fn get-stdio-vec [map]
    [(?. map :stdin :handle) (?. map :stdout :handle) (?. map :stderr :handle)])

  (fn normalize-atom [x]
    (if (= (type x) :function)
        (x)
        x))

  (fn normalize-args [args]
    (icollect [_ x (ipairs args)] (normalize-atom x)))
      
  (fn add-file [pipe filename type last?]
    (table.insert res.files {:handle (uv.fs_open filename 
                                               (case type 
                                                 :write :w
                                                 :append :w+)
                                               (tonumber :644 8)
                                               (fn [err fd]
                                                 (assert (not err) "Failed to open file with error")
                                                 (read-data pipe 
                                                            #(uv.fs_write fd $)
                                                            #(do
                                                               (uv.fs_close fd)
                                                               (when last? (set res.finished true))))))})
    (. res.files (length res.files)))

  (fn shutdown-write [pipe]
    (when pipe
      ; (vim.print "shutting down")
      (uv.shutdown pipe.handle)))

    ; So what are the possible states 
    ; :start - beginning, stdin is nil
    ; :spawn - the previous spec was uv.spawn, stdin is previous stdout
    ; :func - the previous spec was function, change previous stdin (if there is such), change next stdout (if there is such)
    ; :write - the previous spec had :out :write (should be the end)
    ; :append - the previous spec had :out :append (should be the end)

    ; so when we have a function as a state
    ; when we get the value from the previous spec, we need to call function with this value
    ; and store it somewhere for the next thing?
    ; i think i don't care i will just do pipes :)
    ; so we do regular pipe stuff, however in case of a function we just write to stdout ourselves

  (var state :start)
  (var prev-stdout nil)
  (each [i {: path : args : last : file : out} (ipairs specs)]
    (local stdio {:stdin  prev-stdout
                  :stdout (if last nil (create-pipe))})

    (var next-state nil)
    (if (= (type path) :function)
        (do 
          (set next-state :func)
          (read-whole stdio.stdin
                      (fn [data] 
                        (if last
                          (vim.schedule #(do 
                                           (set res.out ((path) data))
                                           (set res.finished true)))
                          (uv.write stdio.stdout
                                    ((path) data)
                                    (fn [err]
                                      (assert (not err) err)
                                      (shutdown-write stdio.stdout)))))))

        out
        (do
          (assert file "Expected file with a output pipe")
          (add-file prev-stdout (normalize-atom file) out last))
          
        (do
          (set next-state :spawn)
          (table.insert res.procs {:handle (uv.spawn path 
                                                     {:args (normalize-args args) :stdio (get-stdio-vec stdio)} 
                                                     (fn [] 
                                                       (shutdown-write stdio.stdout)
                                                       (close-and-set stdio.stdin)
                                                       (close-and-set (. res.procs i))))
                                   :closed false})))
    (set state next-state)
    (set prev-stdout stdio.stdout))

  res)

{: run}


; ; execute commands
; ($$ echo hello > in.txt)
;
; ; with variables
; (let [dir "lua"]
;   ($<_ ls -l #dir))
;
; ; pipe them
; ($$ ps -A | grep browser > out.txt)
;
; ; through user functions
; ($$ ps -A | grep browser | #vim.notify)
;
; (local promise ($! sleep 20 | echo hello | #vim.notify))
; (promise:ready)
; (promise:cancel)
;
; (local args [:a :b :c])
; (get-spec [a b args])
;
; (let [a "hello\nno\nhell\naaaaa"]
;   ($< echo #a | grep hell))
;
; ($< git status #(vim.fn.input "enter dir: "))
;
; ; and get structured data from them
; (let [neogit-lock ($$ cat lazy-lock.json 
;                       | #(fn [json] 
;                            (-> json 
;                                (vim.json.decode) 
;                                (. :neogit))))]
;   neogit-lock.commit)
