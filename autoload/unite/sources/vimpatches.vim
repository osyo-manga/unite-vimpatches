scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#of("vital")
let s:HTTP = s:V.import("Web.HTTP")
let s:url = "http://vim-jp.herokuapp.com/patches/json"


let s:action = {
\	'description' : 'ref-lynx',
\	'is_selectable' : 0,
\}

function! s:action.func(candidate)
	execute "Ref lynx" a:candidate.action__path
endfunction


call unite#custom#action('source/vimpatches/uri', 'ref-lynx', s:action)
unlet s:action



function! s:get_patches(...)
	if exists("s:patches_cache") && !get(a:, 1, 0)
		return deepcopy(s:patches_cache)
	endif
	echo "unite-vimpatches:caching..."
	let result = s:HTTP.request(s:url)
	if result.success != 1
		throw "unite-vimpatches:Failed HTTP request."
		return []
	endif
	let s:patches_cache = eval(result.content)
	return deepcopy(s:patches_cache)
endfunction


let s:source = {
\	"name" : "vimpatches",
\	"description" : "vim patches"
\}

function! s:source.gather_candidates(...)
	return map(s:get_patches(), '{
\		"word" : printf("%s : %s", v:val.id, v:val.description),
\		"kind" : "uri",
\		"action__path" : v:val.link,
\	}')
endfunction

function! unite#sources#vimpatches#define()
	return s:source
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
