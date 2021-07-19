# neovim-shelljob
Async run shell command, and view the raw output, not wraped or breaked by flushing mode.

## Commands

* Start a async job
```
:Job command args " this will start the job and open a buffer with the output
:Job! command args " this starts a job but won't open the output automatically, need use `:JobView` to see the output if need later.
```

* Stop a job
```
:JobStop " this will show a list of running job, you can pick one to stop
```

* List all started jobs
```
:JobList " All jobs would be printed with the command detail and current status
```

* View a job's output
```
:JobView " open the output file of a job
```

* Clean jobs' resources
```
:JobClean " this would close all finished jobs' buffers and remove them from the list
:JobClean! " this would also delete related files
```

## Configuration

The root directory for all those commands output files can be set by `g:asyncjob_dir` variable.
It's defaultly is `/tmp/vim-jobs`.

```vim
let g:asyncjob_dir = 'the dir'
```
