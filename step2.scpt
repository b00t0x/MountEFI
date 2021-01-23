on run {input}
	set targets to choose from list input with multiple selections allowed
	set AppleScript's text item delimiters to ":"
	repeat with target in targets
		set disk to text item 1 of target
		do shell script "diskutil mount " & disk & "s1" with administrator privileges
	end repeat
end run
