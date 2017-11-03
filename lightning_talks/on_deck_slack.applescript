on run argv
  tell application "Slack"
    activate
    tell application "System Events"
      set username to item 1 of argv
      set talk to item 2 of argv

      keystroke "/msg " & username & " FYI: you are on deck"
      keystroke return
    end tell
  end tell
end run
