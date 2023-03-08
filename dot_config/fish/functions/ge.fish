function ge
	if test (count $argv) -eq 0
		grep
		return $status
	end
	set -l matches (grep -Irbo -m1 $argv .)
		or return $status
	set -l tabs 'edit '(echo $matches[1] | cut -d: -f1)
	set -a tabs (math 1 + (echo $matches[1] | cut -d: -f2))go
	for match in $matches[2..-1]
		set -a tabs tabnew
		set -a tabs 'edit '(echo $match | cut -d: -f1)
		set -a tabs (math 1 + (echo $match | cut -d: -f2))go
	end
	set -a tabs 'normal 1gt'
	vim -S (printf '%s\n' $tabs | psub)
end
