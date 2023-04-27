#!/usr/bin/env nu

def main [
    bib_file: string
    result_file: string = ""
] {

    let bib_file = ($bib_file | path expand)
    let result_file = (if $result_file != ""
        { $result_file | path expand }
        else { "./res.ods" | path expand } ) 
    
    let dir = (pwd)
    echo $dir

    let temp_dir = (mktemp -d -q)

    cd $temp_dir

    cp ($env.FILE_PWD | path join "res.tex") .
    
    cp $bib_file ./bib_file.bib
    
    latexmk -f -pdf res.tex

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
      | each { |it| $it | str join | str replace -a '\s{2,}' ' ' }
      | parse -r '^\s*(?P<citekey>\S+\d{4})\s+[\d]+\.\s*(?P<contents>.*)'
      | save -f res.csv
    )

    soffice --convert-to ods res.csv
    # rm res.csv res.bbl res.run.xml 

    mv res.ods $result_file
    cd $dir
    rm -rf $temp_dir
}

