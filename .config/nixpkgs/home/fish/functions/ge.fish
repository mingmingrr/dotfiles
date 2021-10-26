if test (count $argv) -eq 0
	return 1
end
set -l matches (grep -Irbo -m1 $argv .)
if test $status -ne 0
	return $status
end
set -l tabs +(echo $matches[1] | cut -d: -f2)go (echo $matches[1] | cut -d: -f1)
for match in $matches[2..-1]
	set -a tabs "+tabnew +"(echo $match | cut -d: -f2)"go "(echo $match | cut -d: -f1)
end
vim $tabs +1gt
