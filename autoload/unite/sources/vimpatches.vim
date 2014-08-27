scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#of("unite_vimpatches")
let s:HTTP = s:V.import("Web.HTTP")
let s:JSON = s:V.import("Web.JSON")
let s:Reunions = s:V.import("Reunions")
let s:url = "http://vim-jp.herokuapp.com/patches/json"


function! unite#sources#vimpatches#open(version, ...)
	let opencmd = get(a:, 1, "new")
	let pattern = '\(\d\.\d\)\.\(\d\+\)'
	if a:version !~ pattern
		return -1
	endif
	let _ = matchlist(a:version, pattern)
	let url = "http://ftp.vim.org/vim/patches/" . _[1] . "/" . a:version
	let result = s:HTTP.request(url)
	if result.success != 1
		throw "unite-vimpatches:Failed HTTP request."
		return []
	endif
	exec opencmd
	call append(0, split(result.content, "\n"))
	normal! gg
    setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
endfunction


let s:action = {
\	'description' : 'ref-lynx',
\	'is_selectable' : 0,
\}

function! s:action.func(candidate)
	execute "Ref lynx" a:candidate.action__path
endfunction


call unite#custom#action('source/vimpatches/uri', 'ref-lynx', s:action)
unlet s:action


let s:patches_caches = {}
function! s:get_patches(cnt, ...)
	if !has_key(s:patches_caches, a:cnt)
		let s:patches_caches[a:cnt] = s:Reunions.http_get(s:url . "?count=" . a:cnt)
	endif
	if s:patches_caches[a:cnt].is_exit()
		return s:JSON.decode(s:patches_caches[a:cnt].get().content)
	else
		return []
	endif
endfunction



let s:source = {
\	"name" : "vimpatches",
\	"description" : "vim patches",
\	"action_table" : {
\		"openbuf" : {
\			"is_selectable" : 0,
\		},
\	},
\	"count" : 0,
\}


function! s:source.action_table.openbuf.func(candidate)
	echo "open " . a:candidate.source__vimpatch.id . " ..."
	call unite#sources#vimpatches#open(a:candidate.source__vimpatch.id)
endfunction


function! s:source.async_gather_candidates(args, context)
	let a:context.source.unite__cached_candidates = []
	call s:Reunions.update()
	let cnt = get(a:args, 0, 500)
	let result = s:get_patches(cnt)
	if empty(result)
		let self.count += 1
		return [{ "word" : "Donwload patches" . repeat(".", self.count % 5) }]
	endif
	let a:context.is_async = 0
	return map(result, '{
\		"word" : printf("%s : %s", v:val.id, v:val.description),
\		"kind" : "uri",
\		"action__path" : v:val.link,
\		"source__vimpatch" : v:val
\	}')
endfunction


function! unite#sources#vimpatches#define()
	return s:source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
