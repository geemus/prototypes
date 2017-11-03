on run argv
  tell application "Slack"
    activate
    tell application "System Events"
      set username to item 1 of argv
      set talk to item 2 of argv

      keystroke "/msg #lightning-talks " & username & " - " & talk
      keystroke return

      keystroke "/msg " & username & " Start Lightning Talk!"
      keystroke return

      keystroke "/remind " & username & " 4 Minutes Remaining in 1 minutes"
      keystroke return

      keystroke "/remind " & username & " 3 Minutes Remaining in 2 minutes"
      keystroke return

      keystroke "/remind " & username & " 2 Minutes Remaining in 3 minutes"
      keystroke return

      keystroke "/remind " & username & " 1 Minute Remaining in 4 minutes"
      keystroke return

      keystroke "/remind " & username & " Stop Lighting Talking! in 5 minutes"
      keystroke return
    end tell
  end tell
end run
