function is_exists() { type "$1" >/dev/null 2>&1; return $?; }
function is_herdr_running() { [ ! -z "$HERDR_ENV" ]; }
function is_tmux_running() { [ ! -z "$TMUX" ]; }
function is_orca_running() { [ ! -z "$ORCA_TERMINAL_HANDLE" ] || [ ! -z "$ORCA_PANE_KEY" ]; }
function shell_has_started_interactively() { [ ! -z "$PS1" ]; }
function is_ssh_running() { [ ! -z "$SSH_CONNECTION" ]; }

function herdr_automatically_attach_session()
{
    # herdr・tmux・Orcaの中では多重起動しない
    if is_herdr_running || is_tmux_running || is_orca_running; then
        return 0
    fi

    if shell_has_started_interactively && ! is_ssh_running; then
        if ! is_exists 'herdr'; then
            echo 'Error: herdr command not found' 1>&2
            return 1
        fi

        herdr
    fi
}
herdr_automatically_attach_session
