local todo_capture = {
    description = "todo",
    template = "* TODO %? \n%u",
}

local note_capture = {
    description = "note",
    template = "* %? :NOTE:\n%U\n%a\n",
}

local block_agenda = {
    description = "Agenda",
    types = {
        {
            type = "tags",
            match = "REFILE",
            org_agenda_overriding_header = "Tasks to Refile"
        },
        {
            type = "tags_todo",
            match = "-CANCELLED/!",
            org_agenda_overriding_header = "Stuck Projects",
            org_agenda_sorting_strategy = { "category-keep" }
        },
        {
            type = "tags_todo",
            match = "-CANCELLED/!",
            org_agenda_overriding_header = "Projects",
            org_agenda_sorting_strategy = { "category-keep" }
        },
        {
            type = "tags_todo",
            match = "-CANCELLED/!NEXT",
            org_agenda_overriding_header = "Projects Next Tasks",
            org_agenda_sorting_strategy = { "todo-state-down", "effort-up", "category-keep" }
        },
    }
}

return {
    'nvim-orgmode/orgmode',
    event = 'VeryLazy',
    ft = { 'org' },
    config = function()
        local org = require('orgmode')
        org.setup({
            org_agenda_files = '~/orgfiles/**/*.org',
            org_default_notes_file = '~/orgfiles/refile.org',
            org_todo_keywords = {
                "TODO(t)", "WAITING(w)", "THINK(i)", "NEXT(n)", "|", "CANCELLED(c)", "DONE(d)"
            },
            org_capture_templates = {
                t = todo_capture,
                n = note_capture,
            },
            org_agenda_custom_commands = {
                b = block_agenda,
            },
        })
    end,
}
