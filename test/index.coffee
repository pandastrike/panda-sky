import assert from "assert"
import {print, test} from "amen"

do ->

  print await test "PROJECT NAME", [

    test "TEST NAME", ->
      assert true

  ]
