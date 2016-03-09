scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:HTTP = vimpatches#vital_import("Web.HTTP")
let s:JSON = vimpatches#vital_import("Web.JSON")
let s:Reunions = vimpatches#vital_import("Reunions")
let s:Buffer = vimpatches#vital_import("Coaster.Buffer")

let s:url = "https://vim-jp.herokuapp.com/patches/json"



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
\		"open" : {
\			"is_selectable" : 0,
\		},
\	},
\	"count" : 0,
\}


function! s:source.action_table.openbuf.func(candidate)
	call vimpatches#open(a:candidate.source__vimpatch.id)
endfunction


function! s:source.action_table.open.func(candidate)
	call vimpatches#open(a:candidate.source__vimpatch.id)
endfunction


function! s:source.async_gather_candidates(args, context)
	let a:context.source.unite__cached_candidates = []
	call s:Reunions.update()
	let cnt = get(a:args, 0, 500)
	let result = s:get_patches(cnt)
	if empty(result)
		let self.count += 1
		let icon = ["-", "\\", "|", "/"]
		return [{ "word" : icon[self.count % len(icon)] . " Download patches" . repeat(".", self.count % 5) }]
	endif
	let a:context.is_async = 0
	return map(result, '{
\		"word" : printf("%s : %s", v:val.id,
\			substitute(substitute(v:val.description, "\n$", "", ""),
\			"Solution:", repeat(" ", len(v:val.id) + 2)."Solution:", "")),
\		"kind" : "uri",
\		"is_multiline" : 1,
\		"action__path" : v:val.link,
\		"source__vimpatch" : v:val,
\	}')
endfunction


function! unite#sources#vimpatches#define()
	return s:source
endfunction


if expand("%:p") == expand("<sfile>:p")
	call unite#define_source(s:source)
endif


let &cpo = s:save_cpo
unlet s:save_cpo
