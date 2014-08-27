scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#of("unite_vimpatches")


function! vimpatches#vital_import(module)
	return s:V.import(a:module)
endfunction


let s:HTTP = vimpatches#vital_import("Web.HTTP")
let s:JSON = vimpatches#vital_import("Web.JSON")
let s:Reunions = vimpatches#vital_import("Reunions")
let s:Buffer = vimpatches#vital_import("Coaster.Buffer")


" vimpatches#open("7.4.111")
function! vimpatches#open(version, ...)
	let opencmd = get(a:, 1, "split")
	let bufname = printf("vimpatch-%s", a:version)
	echo bufname
	if bufexists(bufname)
		execute opencmd
		execute "buffer" bufnr(bufname)
		return
	endif

	let pattern = '\(\d\.\d\)\.\(\d\+\)'
	if a:version !~ pattern
		return -1
	endif

	let _ = matchlist(a:version, pattern)
	let url = "http://ftp.vim.org/vim/patches/" . _[1] . "/" . a:version
	let process = s:Reunions.http_get(url)
	function! process.then(result, ...)
		call s:Buffer.setbufline(self.bufnr, 1, split(a:result.content, "\n"))
	endfunction
	execute opencmd
	execute "edit" bufname
	setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
	call setline(1, "Loading...")
	let process.bufnr = bufnr("%")
endfunction


augroup vimpatches
	autocmd!
	autocmd CursorHold * call s:Reunions.update_in_cursorhold(1)
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
