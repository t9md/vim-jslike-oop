" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=1:
"============================================================
" Utility Methods:{{{
"============================================================
let sys = {}
fun! sys.init()
    fun! self.puts(...)
        let values = []
        let o = {}
        for o.i in a:000
            if type(o.i) == type({}) && has_key(o.i, "respond_to") && o.i.respond_to("to_s")
                call add(values, o.i.to_s().data)
            else
                call add(values, o.i)
            endif
        endfor
        echo join(values)
    endfun

    fun! self.warn(...)
        echoerr join(a:000)
    endfun

    fun! self.print(...)
        echon join(a:000)
    endfun

    call remove(self, 'init')
endfun
call sys.init()

fun! Test(test_name, clbk)
    echo "============================"
    echo a:test_name
    echo "============================"
    call a:clbk.call()
endfun

"}}}

"============================================================
" Class Object:{{{
"============================================================
let Class = {}
fun! Class.new(...)
  " Forth argment should be prototype Object, if not set, emtpy object is used
  " as prototype
  let args = copy(a:000)
  if len(args) == 3
    call add(args, { 'name': "BasicObject", '_c_methods': {}, '_i_methods': {} })
  endif
  let [class, class_methods, instance_methods, prototype ] = args
  " 'c" stand for [C]lass
  let c = {}
  let c.name = class
  let c.prototype = prototype
  let c._c_methods = class_methods
  let c._i_methods = instance_methods
  call extend(c._c_methods, c.prototype._c_methods, 'error')
  call extend(c, c._c_methods, 'error')

  call extend(c._i_methods, c.prototype._i_methods, 'error')
  let g:{class} = c
endfun

"}}}
"============================================================
" Object: {{{
"============================================================
let object = {}
fun! object.init()
    " Instance methods {{{
    fun! self.im()
        let o = {}

        fun! o.tap(clbk)
            call a:clbk.call(self)
            return self
        endfun

        fun! o.respond_to(meth)
            return has_key(self, a:meth) && type(self[a:meth]) == type(function("call"))
        endfun

        fun! o.to_s()
            return g:String.new(string(self.data))
        endfun

        return o
    endfun
    "}}}
    
    " Class methods {{{
    fun! self.cm()
        let o = {}
        fun! o.instance_methods()
            return g:List.new(keys(self._i_methods))
            " return keys(self._i_methods)
        endfun

        fun! o.class_methods()
            return keys(self._c_methods)
        endfun

        fun! o.alias_method(new, old)
            let self._i_methods[a:new] = self._i_methods[a:old]
        endfun

        fun! o.ancestors()
            let result = [self.name]
            let parent = self.prototype
            while 1
                call add(result, parent.name)
                if parent.name == "BasicObject"
                    break
                endif
                let parent = parent.prototype
            endwh
            return result
        endfun

        fun! o.new(data)
            " 'i" stand for [I]nstance
            let i = {}
            let i.class = self.name
            let i.data = a:data
            call extend(i, self._i_methods, 'error')
            return i
        endfun

        return o
    endfun
    "}}}

    let self.im = self.im()
    let self.cm = self.cm()
endfun
call object.init()
"}}}
"============================================================
" Enumerable: {{{
"============================================================
let enumerable = {}
fun! enumerable.init()
    " Instance methods {{{
    fun! self.im()
        let o = {}
        fun! o.length(...)
            return len(self.data)
        endfun
        return o
    endfun
    "}}}
    
    " Class methods {{{
    fun! self.cm()
        let o = {}
        " code here
        return o
    endfun
    "}}}

    let self.im = self.im()
    let self.cm = self.cm()
endfun
call enumerable.init()
" }}}
"============================================================
" List: {{{
"============================================================
let list = {}
fun! list.init()
    " Instance methods {{{
    fun! self.im()
        let o = {}
        fun! o.join(...)
            let sep = a:0 ? a:1 : "\n"
            return join(self.data, sep)
        endfun

        fun! o.shift()
            return remove(self.data, 0)
        endfun

        fun! o.unshift(val)
            return insert(self.data, a:val, 0)
        endfun

        fun! o.pop()
            return remove(self.data, -1)
        endfun

        fun! o.push(val)
            return add(self.data, a:val)
        endfun

        fun! o.concat(ary)
            return extend(self.data, a:ary)
        endfun

        fun! o.sort()
            return g:List.new(sort(copy(self.data)))
        endfun

        fun! o.uniq()
            let o = {}
            let result = []
            for o.i in self.data
                if !(index(result, o.i) >= 0)
                    call add(result, o.i)
                endif
            endfor
            return result
        endfun
        return o
    endfun
    "}}}
    
    " Class methods {{{
    fun! self.cm()
        let o = {}
        return o
    endfun
    "}}}

    let self.im = self.im()
    let self.cm = self.cm()
endfun
call list.init()
" }}}
"============================================================
" String: {{{
"============================================================
let string = {}
fun! string.init()
    " Instance methods {{{
    fun! self.im()
        let o = {}
        fun! o.capitalize()
            return substitute(self.data,'^\(.\)','\u\1',"")
        endfun

        fun! o.upcase()
            return toupper(self.data)
        endfun

        fun! o.downcase()
            return tolower(self.data)
        endfun
        return o
    endfun
    "}}}
    
    " Class methods {{{
    fun! self.cm()
        let o = {}
        " code here
        return o
    endfun
    "}}}

    let self.im = self.im()
    let self.cm = self.cm()
endfun
call string.init()
"}}}
"============================================================
" Setup: {{{
"============================================================
" Root Object
" let [cm, im] = object.init()
call Class.new("Object", object.cm, object.im)

" Enumerable < Object
call Class.new("Enumerable", enumerable.cm, enumerable.im, Object)

" List < Enumerable < Object
call Class.new("List", list.cm, list.im, Enumerable)
" alias_method :size, :length
call List.alias_method("size", "length")
" alias_method :nagasa, :length
call List.alias_method("nagasa", "length")

" String < List < Enumerable < Object
call Class.new("String", string.cm, string.im, List)
" echo String.ancestors()
" }}}
"============================================================
" Usage: {{{
"============================================================
" len() could be used for Both string and list, so set prototype of String to
" List is effective for length() method
" [TODO] make shared method to module and include in each class ex) Enumerable
"------------------------------------------------------------
command! -nargs=* H :echo "--------"
command! -nargs=1 TEST :echo "====" <args> "====="

let clbk = {}
fun! clbk.call()
    let clbk = {}
    fun! clbk.call(e)
        echo "In tap()"
        echo a:e.data
        echo "Out tap()"
    endfun
    echo g:List.instance_methods().tap(clbk).length()
    " => In tap()
    "    ['size', 'unshift', 'length', 'nagasa', 'join', 'to_s', 'tap', 'concat', 'push', 'pop', 'sort', 'uniq', 'shift', 'respond_to']
    "    Out tap()
    "    14
endfun
call Test("List(1)", clbk)

fun! clbk.call()
    echo g:String.new("abc_def").capitalize() |" => Abc_def
    echo g:String.new("abcdef").upcase()      |" => ABCDEF
    echo g:String.new("ABCDEF").downcase()    |" => abcdef
    echo g:String.new("ABCDEF").length()      |" => 6
    echo g:String.new("ABCDEF").nagasa()      |" => 6
    echo g:String.new("ABCDEF").size()        |" => 6
endfun
call Test("String", clbk)

fun! clbk.call()
    echo g:List.prototype.name|" => Enumerable
    let  lis = g:List.new([1,2,3,4])
    echo lis.class            |" => List
    echo lis.length()         |" => 4
    echo lis.size()           |" => 4
    echo lis.nagasa()         |" => 4

    TEST "List#uniq()"
    let clbk = {}
    fun! clbk.call(e)
        call g:sys.puts("before uniq():", a:e)
    endfun
    let after_uniq = g:List.new([1,3,3,4,11,9,9,1]).sort().tap(clbk).uniq()
    call g:sys.puts("after uniq():", after_uniq)
endfun
call Test("List(2)", clbk)


fun! clbk.call()
    call g:sys.puts(g:List.instance_methods())
    " => ['size', 'unshift', 'length', 'nagasa', 'join', 'to_s', 'tap', 'concat', 'push', 'pop', 'sort', 'uniq', 'shift', 'respond_to']
    call g:sys.puts(g:List.class_methods())
    " =>['instance_methods', 'class_methods', 'alias_method', 'ancestors', 'new']
endfun
call Test("Refrection", clbk)

fun! clbk.call()
    let  lis = g:List.new([1,2,3,4])
    echo lis.join()
    " => 1
    "    2
    "    3
    "    4
    echo lis.join(':')        |" => 1:2:3:4
    echo lis.join('/')        |" => 1/2/3/4
    TEST "data"
    echo lis.data             |" => [1, 2, 3, 4]
    TEST "shift()"
    echo lis.shift()          |" =>  1
    echo lis.data             |" => [2, 3, 4]
    TEST "shift()"
    echo lis.shift()          |" => 2
    echo lis.data             |" => [3,4]
    TEST "pop()"
    echo lis.pop()            |" => 4
    echo lis.data             |" => [3]
    TEST "unshift(99)"
    echo lis.unshift(99)      |" => [99,3]
    echo lis.data             |" => [99,3]
    TEST "push(99)"
    echo lis.push(99)         |" => [99,3,99]
    echo lis.data             |" => [99,3,99]
    TEST "push([99])"
    echo lis.push([99])       |" => [99, 3, 99, [99]]
    echo lis.data             |" => [99, 3, 99, [99]]
    TEST "concat([1,2,3,4])"
    echo lis.concat([1,2,3,4])|" => [99, 3, 99, [99], 1, 2, 3, 4]
    echo lis.data             |" => [99, 3, 99, [99], 1, 2, 3, 4]
endfun
call Test("List(3)", clbk)
finish
" }}}
