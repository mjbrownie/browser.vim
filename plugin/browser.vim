"browser.vim Super lightweight browser for vim (uses lynx Dump)
" Script Info and Documentation  {{{1
"=============================================================================
"    Copyright: Copyright (C) 2008 Michael Brown
"      License: The MIT License
"               
"               Permission is hereby granted, free of charge, to any person obtaining
"               a copy of this software and associated documentation files
"               (the "Software"), to deal in the Software without restriction,
"               including without limitation the rights to use, copy, modify,
"               merge, publish, distribute, sublicense, and/or sell copies of the
"               Software, and to permit persons to whom the Software is furnished
"               to do so, subject to the following conditions:
"               
"               The above copyright notice and this permission notice shall be included
"               in all copies or substantial portions of the Software.
"               
"               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"               OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"               MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"               IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"               CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"               TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"               SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" Name Of File: browser.vim
"  Description: Simple internal web browser for vim
"   Maintainer: Michael Brown 
"  Last Change:
"          URL:
"      Version: 0.1.1
"
"        Usage:
"
"               This script requires the lynx browser
"
"               Place browser.vim in your plugin folder
"
"               This plugin opens a website by making a lynx -dump call behind
"               the scenes and takes advantage of the dumps link references so
"               you can click on links and browse through a site.
"
"               It seems to work well on wikipedia and any text friendly sites
"               when all you want is a quick definition etc.
"
"               :WebBrowser <url>
"               To open a web page
"
"               :Wikipedia <search term>
"               Will open en.wikipedia.org/wiki/<search term> 
"
"               :Google <serch term>
"               Opens google to the search term
"
"               :GoogleLucky <serch term>
"               Opens Lucky Google search 
"
"               :VimScript <search term>
"               Opens a Vim Script option
"
"               you can also create your own site specific googling eg.  
"               com! -nargs=+ GooglePythonDoc call OpenGoogle(<q-args>, 0 , 'docs.python.org')
"               (make the second arg 1 for lucky)
"               
"               Within the browser view the <tab> key cycles through links and
"               pressing <cr> will open a link
"
"               the u key seems to work ok as a back button 
"
"
"         Bugs:
"               Internal url's with #anchor will not work
"               Clicking on an image link will not work 
"               Not yet ACID compliant. 
"
"
"        To Do:
"               Please send in any filetype keywordprg hacks you have for any
"               specific languages and I'll add them to the script
"
"               (mjbrownie at please dont spam my gmail.com account )

"
"Configuration
"
"Possible mappings if your not using the default keywordprg
"map K :Wikipedia <c-r><c-w><cr>
"au FileType php map K :call OpenPhpFunction('<c-r><c-w>', g:browser_split )<cr>
"au FileType python map K :GooglePythonDoc <cword><cr>
"}}}

let g:browser_split = 'vert belowright split' " 'split'
"Commands {{{1 
com! -nargs=+ Wikipedia        call OpenWikipedia(<q-args>,g:browser_split)
com! -nargs=+ WikipediaT       call OpenWikipedia(<q-args>,'tabnew')
com! -nargs=+ Dictionary       call OpenDictionary(<q-args>,g:browser_split)
com! -nargs=+ DictionaryT      call OpenDictionary(<q-args>,'tabnew')
com! -nargs=+ WebBrowser       call OpenWebBrowser(<q-args>,g:browser_split)
com! -nargs=+ WebBrowserT      call OpenWebBrowser(<q-args>,'tabnew')
com! -nargs=+ GoogleLucky      call OpenGoogle(<q-args>, 1, '',g:browser_split)
com! -nargs=+ GoogleLuckyT     call OpenGoogle(<q-args>, 1, '','tabnew')
com! -nargs=+ Google           call OpenGoogle(<q-args>, 0 , '',g:browser_split)
com! -nargs=+ GoogleT          call OpenGoogle(<q-args>, 0 , '', 'tabnew')
com! -nargs=+ GooglePythonDoc  call OpenGoogle(<q-args>, 0 , 'docs.python.org',g:browser_split)
com! -nargs=+ GooglePythonDocT call OpenGoogle(<q-args>, 0 , 'docs.python.org',g:browser_split)
com! -nargs=+ Django           call OpenGoogle(<q-args>, 1 , 'docs.djangoproject.com',g:browser_split)
com! -nargs=+ DjangoT          call OpenGoogle(<q-args>, 1 , 'www.djangoproject.com','tabnew')
com! -nargs=+ StackOverflow    call OpenStackOverflow(<q-args>, g:browser_split)
com! -nargs=+ GoogleVimOrg     call OpenGoogle(<q-args>, 0 , 'vim.org',g:browser_split)
com! -nargs=+ GoogleVimOrgT    call OpenGoogle(<q-args>, 0 , 'vim.org','tabnew')
com! -nargs=+ VimScript        call VimScriptSearch(<q-args>,g:browser_split)
com! -nargs=+ VimScriptT       call VimScriptSearch(<q-args>,'tabnew')
com! -nargs=+ VimTip           call VimTipSearch(<q-args>,g:browser_split)
com! -nargs=+ VimTipT          call VimTipSearch(<q-args>,'tabnew')


"OpenWebBrowser  {{{1
fun! OpenWebBrowser (address, method)
  exe a:method . " " . a:address
  exe "set buftype=nofile"
  exe "silent r!lynx -dump " . a:address
  exe "set syntax=text"
  "add some syntax rules (thanks to jamesson on #vim)
  syn match Underlined /\[\d*\]\w*/ contains=LineNr
  syn match LineNr /\[\d*\]/ contained
  exe "norm gg"
  exe "nnoremap <buffer> <tab> /\\[\\d\\+\\]\\w*/b+1<cr>"
  exe 'nnoremap <buffer> <cr> F[h/^ *<c-r><c-w>. http<cr>fh"py$:call OpenLink("<c-r>p", "edit")<cr>'
  exe 'nnoremap <buffer> <c-cr> F[h/^ *<c-r><c-w>. http<cr>fh"py$:call OpenLink("<c-r>p","tabnew")<cr>'
endfun

"OpenLink {{{1
fun! OpenLink (address, method)
  let clean_address = ''
  let clean_address = substitute(a:address, '%', '\\%','g')
  let clean_address = substitute(clean_address, '#', '\\#','g')
  let clean_address = substitute(clean_address, '&', '\\&','g')
  call OpenWebBrowser(clean_address, a:method)
endfun

"CallLynx {{{1
fun! CallLynx(address)
    "get Headers
    let headers = system('lynx -head -dump ' . a:address)
    "echo headers
    let filename = matchstr(headers, 'filename=[^\n]*\n')
    echo filename
    let content_type = matchstr(headers, 'Content-Type: .*\n')
    echo content_type
    "application/octetstream
    "text/html
    "image/png
endfun

"OpenGoogle {{{1
fun! OpenGoogle (sentence,lucky,site,method)
    if a:site != ''
        let site_clause = '\+site\%3A' . a:site
    else
        let site_clause = ''
    endif

    if a:lucky == 1
        let type = 'btnI'
    else
        let type = 'btnG'
    endif

    let topic = substitute(a:sentence, " ", "+", "g") 
    let address = 'http://www.google.com/search\?'.type.'=yes\&q=' . topic .site_clause
    call OpenWebBrowser(address, a:method)
endfun
"OpenWikipedia {{{1
fun! OpenWikipedia (sentence,method)
    let topic = substitute(a:sentence, " ", "_", "g") 
    let address = 'http://www.wikipedia.org/wiki/' . topic
    "echo address
    call OpenWebBrowser(address, a:method)
    exe "norm 5dd"
endfun
"WikipediaRange {{{1
fun! WikipediaRange() range
    let sentence = @a
    call OpenWikipedia(sentence)
endfun
"OpenDictionary {{{1
fun! OpenDictionary (sentence,method)
    let topic = substitute(a:sentence, " ", "_", "g") 
    let address = 'http://www.thefreedictionary.com/' . topic
    "let address = 'http://en.wiktionary.org/wiki/' . topic
    call OpenWebBrowser(address, a:method)
endfun
"VimScriptSearch {{{1
fun! VimScriptSearch(sentence,method)
    let topic = substitute(a:sentence, " ", "_", "g") 
    let address = 'http://www.vim.org/scripts/script_search_results.php\?script_type=\&order_by=rating\&direction=descending\&search=search\&keywords=' . topic
    "echo address
    call OpenWebBrowser(address, a:method)
    exe "norm 19dd"
endfun
"VimTipSearch {{{1
fun! VimTipSearch(sentence,method)
    let topic = substitute(a:sentence, " ", "_", "g") 
    let address = 'http://www.vim.org/tips/tip_search_results.php\?order_by=rating\&direction=descending\&search=search\&keywords=' . topic
    "echo address
    call OpenWebBrowser(address, a:method)
    exe "norm 19dd"
endfun
"OpenPhpFunction {{{1
fun! OpenPhpFunction (keyword,method)
    "let address = 'http://www.php.net/' . a:keyword
    "call OpenWebBrowser(address, a:method)
    let proc_keyword = substitute(a:keyword , '_', '-', 'g')
    exe 'split'
    exe 'enew'
    exe "set buftype=nofile"
    exe 'silent r!lynx -dump -nolist http://www.php.net/manual/en/print/function.'.proc_keyword.'.php' 
    exe 'norm gg'
    exe 'call search ("' . a:keyword .'")'
    exe 'norm dgg'
    exe 'call search("User Contributed Notes")' 
    exe 'norm dGgg'
endfun

"OpenStackOverflow  {{{1
fun! OpenStackOverflow (keyword,method)
    "let address = 'http://www.php.net/' . a:keyword
    "call OpenWebBrowser(address, a:method)
    let proc_keyword = substitute(a:keyword , '_', '-', 'g')
    let proc_keyword = substitute(proc_keyword , ' ', '+', 'g')
    call OpenWebBrowser('http://stackoverflow.com/search?q='.proc_keyword, a:method)
endfun
