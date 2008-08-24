pro empty_trash
  script = [ 'tell application "Finder" ', $
             'empty', $
             'end tell' ]
  do_apple_script, script
end