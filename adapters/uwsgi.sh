uwsgiCgiAdapter() {
  [ $# -eq 0 ] && { echo "Missing required argument for uwsgiCgiAdapter: [start|stop]" >&2; return 1; }

  local command="$1"
  shift

  case "$command" in

    start)
      [ $# -eq 0 ] && { echo  "Missing required argument for uwsgiCgiAdapter start: [CGI script path]" >&2; return 1; }

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
          echo "Unsupported uwsgiCgiAdapter start argument: $1. Expected [CGI script path]." >&2
          return 1
        fi
      done

      # TODO add host option
      # --host "$host" "$cgi_script" &>/dev/null &

      local cgi_script_name="${cgi_script/*\/}"
      local cgi_script_dir="${cgi_script%\/*}"

      # Run uwsgi CGI server to host this CGI script
      local pid=""
      uwsgi --master --processes 1 --plugins http,cgi --http :$port --http-modifier1 9 --cgi "$cgi_script_name" --chdir "$cgi_script_dir" &
      pid=$!

      # Wait for it to start (requires curl)
      # Wait ~5 seconds (50 attempts with 0.1 sleeps)
      local timeout=50
      local attempts=0
      while true
      do
        (( attempts++ ))
        if [ $attempts -gt $timeout ]
        then
          echo "uwsgiCgiAdapter error. Started script but cannot 'curl' running script successfully. Might be a problem with your CGI script or uwsgi is missing from your system." >&2
          return 1
        fi
        if curl -i "http://$host:$port/" &>/dev/null
        then
          break
        else
          sleep 0.1
        fi
      done

      echo "Running CGI script [$cgi_script]" >&2
      echo "http://$host:$port/" >&2

      printf "Server identifier: " >&2
      printf "$pid"
      echo >&2

      return 0
      ;;

    stop)
      [ $# -eq 0 ] && { echo "Missing required argument for uwsgiCgiAdapter stop: [server identifier returned from 'uwsgiCgiAdapter start']" >&2; return 1; }
      [ $# -gt 1 ] && { echo "Too many arguments provided to uwsgiCgiAdapter stop. Expected 1: [server identifier returned from 'uwsgiCgiAdapter start']. Received $# ($*)." >&2; return 1; }
      [[ ! $1 =~ ^[0-9]+$ ]] && { echo "Invalid uwsgiCgiAdapter server identifier: $1. Should be numeric." >&2; return 1; }

      local pid="$1"

      local runningPids=""
      runningPids="$( ps ax | grep "uwsgi" | grep -v grep | awk '{ print $1 }' )"
      if [ -n "$runningPids" ]
      then
        if [[ "$runningPids" = *"$pid"* ]]
        then
          
          # Send INT
          kill -s INT "$pid"

          # Verify it's not still running
          local timeout=100
          local attempts=0
          while true
          do
            (( attempts++ ))
            if [ $attempts -gt $timeout ]
            then
              echo "uwsgiCgiAdapter error. Server was not stopped. Try running this command to reproduce: kill -s INT $pid" >&2
              return 1
            fi
            runningPids="$( ps ax | grep "uwsgi" | grep -v grep | awk '{ print $1 }' )"
            if [[ "$runningPids" != *"$pid"* ]]
            then
              echo "Stopped CGI script [$pid]" >&2
              return 0
            fi
            sleep 0.1
          done

        else
          echo "uwsgiCgiAdapter instance not running: $pid" >&2
          return 1
        fi
      else
        # No running instances
        echo "No running uwsgiCgiAdapter instances found to stop" >&2
        return 1
      fi

      ;;

    *)
      echo "Unsupported uwsgiCgiAdapter command: $command. Expected 'start' or 'stop'" >&2
      return 1
      ;;

  esac
}
