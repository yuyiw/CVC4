;COMMAND-LINE: --dt-nested-rec
;EXPECT: unsat
(set-logic ALL)
(declare-fun tickleBool (Bool) Bool)
(assert (and (tickleBool true) (tickleBool false)))
(declare-datatypes ((T@Value 0)(T@ValueArray 0)) (((Integer (|i#Integer| Int) ) (Vector (|v#Vector| T@ValueArray) ) ) ((ValueArray (|v#ValueArray| (Seq T@Value)) ) ) ))
(declare-fun ControlFlow (Int Int) Int)
(declare-fun s@0 () T@ValueArray)
(declare-fun s@1 () T@ValueArray)
(declare-fun s@2 () T@ValueArray)
(declare-fun s@3 () T@ValueArray)
(declare-fun s@4 () T@ValueArray)
(declare-fun s@5 () T@ValueArray)
(set-info :boogie-vc-id test)
(assert (not
 (=> (= (ControlFlow 0 0) 427) (let ((anon0_correct  (=> (= s@0 (ValueArray (as seq.empty (Seq T@Value)))) (and (=> (= (ControlFlow 0 331) (- 0 448)) (= (seq.len (|v#ValueArray| s@0)) 0)) (=> (= (seq.len (|v#ValueArray| s@0)) 0) (=> (= s@1 (ValueArray (seq.++ (|v#ValueArray| s@0) (seq.unit (Integer 0))))) (=> (and (= s@2 (ValueArray (seq.++ (|v#ValueArray| s@1) (seq.unit (Integer 1))))) (= s@3 (ValueArray (seq.++ (|v#ValueArray| s@2) (seq.unit (Integer 2)))))) (and (=> (= (ControlFlow 0 331) (- 0 490)) (= (seq.len (|v#ValueArray| s@3)) 3)) (=> (= (seq.len (|v#ValueArray| s@3)) 3) (and (=> (= (ControlFlow 0 331) (- 0 497)) (= (seq.nth (|v#ValueArray| s@3) 1) (Integer 1))) (=> (= (seq.nth (|v#ValueArray| s@3) 1) (Integer 1)) (=> (= s@4 (ValueArray (seq.extract (|v#ValueArray| s@3) 0 (- (seq.len (|v#ValueArray| s@3)) 1)))) (and (=> (= (ControlFlow 0 331) (- 0 517)) (= (seq.len (|v#ValueArray| s@4)) 2)) (=> (= (seq.len (|v#ValueArray| s@4)) 2) (=> (= s@5 (ValueArray (seq.++ (|v#ValueArray| s@4) (|v#ValueArray| s@4)))) (and (=> (= (ControlFlow 0 331) (- 0 534)) (= (seq.len (|v#ValueArray| s@5)) 4)) (=> (= (seq.len (|v#ValueArray| s@5)) 4) (=> (= (ControlFlow 0 331) (- 0 541)) (= (seq.nth (|v#ValueArray| s@5) 3) (Integer 1))))))))))))))))))))
(let ((PreconditionGeneratedEntry_correct  (=> (= (ControlFlow 0 427) 331) anon0_correct)))
PreconditionGeneratedEntry_correct)))
))
(check-sat)
