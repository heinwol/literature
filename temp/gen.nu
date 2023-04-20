#!/usr/bin/env nu

# latexmk -f -pdf res.tex
# sleep 500ms
# latexmk -c

pdftotext -nopgbrk -layout res.pdf

(open res.txt 
  | lines
  | range 1..
  | filter {|it| $it !~ '^\d$'} 
  | each { |it|
      (if ($it =~ '^\s*\S+\d{4}\s+[\d]+\.([^\d].*|$)') 
          and ($it !~ '^[\d]{3,}') 
          { ["-----", $it] }
          else $it )}
  | flatten
  | split list '-----'
  | each { |it| $it | str join | str replace -a '\s{2,}' ' ' | $in + "\n" }
  | save -f res.txt
)
