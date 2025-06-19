(module
  (import "host" "print"
    (func $print (param (; pointer ;) i32 (; length ;) i32)))
  (export "main" (func $main))

  (memory $memory 1)
  (export "memory" (memory $memory))

  ;; n! = n * (n - 1) * (n - 2) * ... * 2 * 1
  (func $factorial (param $arg i64) (result i64)
    local.get $arg
    i64.eqz
    if (result i64)
      i64.const 1

    else
      local.get $arg
      i64.const 1
      i64.sub
      call $factorial
      local.get $arg
      i64.mul
  )

  (func $main (result i64)
    i64.const 10
    call $factorial
    i32.const 0
    i32.const 13
    call $print
  )

  (data (i32.const 0) "Hello, World!")
)
