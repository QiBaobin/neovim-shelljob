if exists('g:loaded_asyncjob')
  finish
endif
let g:loaded_asyncjob = 1

if !exists('g:asyncjob_dir')
  let g:asyncjob_dir = '/tmp/vim-jobs'
endif
let s:jobs = {}

function! s:OnEvent(job_id, data, event) dict
  let job = s:jobs[a:job_id]
  let win_id = bufwinid(job['file'])
  if win_id >= 0
    let last_win = win_getid()
    call win_gotoid(win_id)
    call s:View(a:job_id)
    call win_gotoid(last_win)
  endif

  if a:event == 'stdout' || a:event == 'stderr'
    if job['status'] == 'Pending'
      let job['status'] = 'In Progress'
    endif
  else
    let job['status'] = 'Finished'
    call s:List(a:job_id)
  endif
endfunction
let s:callbacks = {
      \ 'on_stdout': function('s:OnEvent'),
      \ 'on_stderr': function('s:OnEvent'),
      \ 'on_exit': function('s:OnEvent')
      \ }
function! s:List(job_id='', status = '', ...) abort
  echomsg "Jobs:"
  for [next_key, next_val] in items(s:jobs)
    if next_key =~ a:job_id && next_val['status'] =~ a:status
      echomsg next_key . ': ' . next_val['cmd'] . ' -- ' . next_val['status']
    endif
  endfor
endfunction
function! s:Stop(job = '') abort
  call s:List('', 'Pending\|In Progress')
  let job_nn = a:job != '' ? a:job : input('Which one: ')
  if job_nn != '' && job_nn != 0
    call jobstop(str2nr(job_nn))
  endif
endfunction
function! s:View(job = '') abort
  let job_nn = a:job != '' ? a:job : input('Which one: ')
  if job_nn != '' && job_nn != 0
    exe  'view! +normal\ G ' . s:jobs[job_nn].file
  endif
endfunction
function! s:Start(cmd, bang) abort
  call mkdir(g:asyncjob_dir, "p", 0700)

  let file = g:asyncjob_dir . '/' . substitute(a:cmd,' .*','','') . strftime("@%T")
  let job = jobstart(a:cmd . " 2>&1 | tee '" . file . "'", s:callbacks)

  if job <= 0
    finish
  endif
  let s:jobs[job] = {'file': file, 'status': 'Pending', 'cmd': a:cmd}
  if a:bang ==# ''
    call s:View(job)
  endif
endfunction
function! s:Clean(bang) abort
  for [next_key, next_val] in items(s:jobs)
    if next_val['status'] =~ 'Finished'
      exe 'bdelete ' next_val['file']
      if a:bang != ''
        exe '!rm ' next_val['file']
      endif
      unlet s:jobs[next_key]
    endif
  endfor
endfunction

command! -nargs=+ -bang -complete=shellcmd Job call s:Start(<q-args>, <q-bang>)
command! -nargs=0 JobList call s:List()
command! -nargs=0 JobStop call s:Stop()
command! -nargs=0 JobView call s:List() | call s:View()
command! -nargs=0 JobClean call s:Clean(<q-bang>) | call s:List()
