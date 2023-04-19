#!/usr/bin/env nu

latexmk -pdf res.tex
latexmk -c

pdftotext -nopgbrk res.pdf; open res.txt | lines | filter {|it| not ($it =~ '^\d$')} | each {|it| if ($it =~ '^[\d]+\.([^\d].*|$)') {["-----", $it]} else $it } | flatten | split list '-----' | each { |it| $it | str join | $in + "\n" } | save -f res.txt
