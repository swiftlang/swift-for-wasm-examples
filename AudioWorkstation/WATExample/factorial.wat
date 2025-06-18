(module
  (import "host" "print"
    (func $print (param (; pointer ;) i32 (; length ;) i32)))
  (export "main" (func $main))

  (memory $memory 1)
  (export "memory" (memory $memory))

  ;; n! = n * (n - 1) * (n - 2) * ... * 2 * 1
  (func $factorial (param $arg i64) (result i64)
    (if (result i64)
      (i64.eqz (local.get $arg))
      (then (i64.const 1))
      (else
        (i64.mul
          (local.get $arg)
          (call $factorial
            (i64.sub
              (local.get $arg)
              (i64.const 1)
            ))))))

  (func $main (result i64)
    (call $factorial (i64.const 10))
    (call $print (i32.const 0) (i32.const 13))
  )

  (data (i32.const 0) "Hello, World!")
)
