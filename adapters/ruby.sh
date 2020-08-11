rubyCgiAdapter() {
  [ $# -eq 0 ] && { echo "Missing required argument for rubyCgiAdapter: [start|stop]" >&2; return 1; }

  local command="$1"
  shift

  local rubyServerScript="${BASH_SOURCE[0]/ruby.sh}ruby-cgi-server.rb"

  case "$command" in

    start)
      [ $# -eq 0 ] && { echo  "Missing required argument for rubyCgiAdapter start: [CGI script path]" >&2; return 1; }

      local cgi_script=""
      local port=8080
      local host=127.0.0.1

      while [ $# -gt 0 ]
      do
        if [ "$1" = "-p" ] || [ "$1" == "--port" ]
        then
          shift
          port="$1"
          shift
        elif [ "$1" = "-h" ] || [ "$1" == "--host" ]
        then
          shift
          host="$1"
          shift
        elif [ -f "$1" ]
        then
          if [ -x "$1" ]
          then
            cgi_script="$1"
            shift
          else
            echo "CGI script found but not executable: $1. Please chmod +x this script and try again." >&2
            return 1
          fi
        else
          echo "Unsupported rubyCgiAdapter start argument: $1. Expected [CGI script path]." >&2
          return 1
        fi
      done

      # Run Ruby CGI server to host this CGI script
      local pid=""
      "$rubyServerScript" --host "$host" --port "$port" "$cgi_script" &>/dev/null &
      pid=$!

      echo "$pid"

      echo "Running CGI script [$cgi_script]" >&2
      echo "Server identifier [$pid]" >&2
      echo "http://$host:$port/" >&2
      return 0
      ;;

    stop)
      [ $# -eq 0 ] && { echo "Missing required argument for rubyCgiAdapter stop: [server identifier returned from 'rubyCgiAdapter start']" >&2; return 1; }
      [ $# -gt 1 ] && { echo "Too many arguments provided to rubyCgiAdapter stop. Expected 1: [server identifier returned from 'rubyCgiAdapter start']. Received $# ($*)." >&2; return 1; }
      [[ ! $1 =~ ^[0-9]+$ ]] && { echo "Invalid rubyCgiAdapter server identifier: $1. Should be numeric." >&2; return 1; }

      local pid="$1"

      local runningPids=""
      runningPids="$( ps -C "ruby $rubyServerScript" -o pid= )"
      if [ $? -eq 0 ]
      then
        if [[ "$runningPids" = *"$pid"* ]]
        then
          
          # Send INT
          kill -s INT "$pid"

          # Verify it's not still running
          runningPids="$( ps -C "ruby $rubyServerScript" -o pid= )"
          if [[ "$runningPids" = *"$pid"* ]]
          then
            echo "rubyCgiAdapter error. Server was not stopped. Try running this command to reproduce: kill -s INT $pid" >&2
            return 1
          else
            echo "Stopped CGI script [$pid]" >&2
            return 0
          fi

        else
          echo "rubyCgiAdapter instance not running: $pid" >&2
          return 1
        fi
      else
        # No running instances
        echo "No running rubyCgiAdapter instances found to stop" >&2
        return 1
      fi

      ;;

    *)
      echo "Unsupported rubyCgiAdapter command: $command. Expected 'start' or 'stop'" >&2
      return 1
      ;;

  esac
}