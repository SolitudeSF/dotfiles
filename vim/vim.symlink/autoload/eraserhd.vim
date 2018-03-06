let s:ReplCommands = {
  \ "clojure": "lein repl" ,
  \ "idris": "idris" }

function! eraserhd#todo_filename()
  let l:project_name = fnamemodify(getcwd(), ":t")
  return $HOME . "/src/data/" . l:project_name . "-todo.md"
endfunction

function! eraserhd#configure()
  if exists("t:eraserhd_configured") && t:eraserhd_configured
    return
  endif
  let t:eraserhd_configured = 1
  let l:original_window = winnr()
  if has_key(s:ReplCommands, &filetype)
    let l:repl_command = s:ReplCommands[&filetype]
  else
    let l:repl_command = ""
  endif
  if has('nvim')
    below vsplit term://bash\ -l
  else
    below vertical term bash -l
    setlocal nonumber
  endif
  let b:eraserhd_tag = "repl"
  wincmd L
  execute "split " . eraserhd#todo_filename()
  10wincmd _
  set winfixheight
  let b:eraserhd_tag = "todo"
  execute l:original_window . "wincmd w"
  if l:repl_command != ""
    call term_sendkeys(eraserhd#special_buffer("repl"), l:repl_command . "\<CR>")
  endif
endfunction

function! eraserhd#special_buffer(tag)
  for l:i in tabpagebuflist()
    if getbufvar(l:i, "eraserhd_tag") ==# a:tag
      return l:i
    endif
  endfor
  return -1
endfunction

function! eraserhd#run_repl_command(cmd)
  call eraserhd#configure()
  let l:repl_buffer = eraserhd#special_buffer("repl")
  if l:repl_buffer ==# -1
    echoe "No terminal found!"
    return
  endif
  call term_sendkeys(l:repl_buffer, a:cmd . "\<CR>")
endfunction

function! eraserhd#repeat_last_repl_command()
  call eraserhd#run_repl_command("\<C-P>")
endfunction

function! eraserhd#goto(what, ...)
  call eraserhd#configure()
  let l:bufnr = eraserhd#special_buffer(a:what)
  if l:bufnr == -1
    echoe "Can't find special buffer '" . a:what . "'"
    return
  endif
  execute bufwinnr(l:bufnr) . "wincmd w"
endfunction