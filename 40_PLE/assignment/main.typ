#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  Slip - Coroutines
]

#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Milan Lagae],
    email: [],
    mark: [],
  ),
)

#let affiliations = (
  (
    name: [Institution/University Name:],
    faculty: [Faculty:],
    course: [Course:],
  ),
  (
    name: [Vrije Universiteit Brussel],
    faculty: [Sciences and Bioengineering Sciences],
    course: [Programming Language Engineering],
  ),
)

#let conference = (
  name: [],
  short: [],
  year: [],
  date: [],
  venue: [],
)


#let doi = "/"

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: none,
  doi: doi,
  copyright: none,
  // Font Size as described by the assignment
  font-size: 11pt,
)


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 0.75em, below: 0.25em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)



#colbreak()
= Intro

This report will discuss an implementation for the assignment "Exam assignment: Coroutines" for the course:"Programming Language Engineering".

First, the special form: `newprocess` will be discussed in section @newprocess. Followed by the implementation of `transfer` in section @transfer.



// = Slip Version

// TODO: Update to correct version
// The Slip version used to implement the assignment, is version 11, but first class continuations are not implemented.


#colbreak()
= `newprocess` <newprocess>


Adding the `newprocess` special form is done by adding all the same additions as the other special forms defined in the interpreter.


== Preparations

This subsection describes the preparations required to compile & evaluate the special form `newprocess`.


=== Definitions

Start of by defining the name of the special form to be created, by creating a new text string as shown in @special-form-str.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    static const TXT_type Main_Newprocess_String = "newprocess";
    ```,
  ),
  caption: "Special Form String Declaration",
) <special-form-str>


Define the symbol type of `Main_Newp` so the compiler is able to parse said expression, as shown in @special-form-type & @special-form-type-extern.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    SYM_type Main_Newp;
    ```,
  ),
  caption: "Special Form Type",
) <special-form-type>

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    extern SYM_type Main_Newp;
    ```,
  ),
  caption: "Special Form Type Extern",
) <special-form-type-extern>


For the REPL to be able to detect `newprocess` in the REPL & Reclaim, are added as shown in @special-form-reclaim & @special-form-repl.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp      = Pool_Enter(Main_Newprocess_String);
    ```,
  ),
  caption: "Special Form Reclaim",
) <special-form-reclaim>


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Newp               = Pool_Initially_Enter(Main_Newprocess_String);
    ```,
  ),
  caption: "Special Form REPL",
) <special-form-repl>




=== Grammar

// TODO: Update to correct sentence
Define the `NEP_tag`, similar to tags for `while` expression, as shown in @grammar-h-neptag.

// TODO: Update code
#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    NEP_tag = 0x16 << 1 | 0x0,
    ```,
  ),
) <grammar-h-neptag>

The definition of a struct `NEP` based on the `NEP_type` in @grammar-h-neptype.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    typedef struct NEP *NEP_type;
    ```,
  ),
) <grammar-h-neptype>


In the `Grammar.h` file, the NEP type is added as shown in @grammar-h-neptype-impl.


// TODO: Update code
#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    typedef
    struct NEP {
        CEL_type hdr;
        EXP_type name;
        VEC_type bod;
        NBR_type bsz;
    } NEP;
    ```,
  ),
) <grammar-h-neptype-impl>

A matching `make_NEP` function is defined in `Grammar.c` file.


=== Compile

For the compilation function, the operator matches on the `Main_Newp` symbol tag, as shown in @compile-operator.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    if (operator == Main_Newp)
          return compile_newprocess(operands);
    ```,
  ),
  caption: "Compilation operator detection",
) <compile-operator>


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    case NEP_tag:
    ```,
  ),
  caption: "Compilation tag, error fall through",
) <compile-tag>



== Compilation


The structure of the compilation is similar to that of other special form expressions.

Start of with survival claiming the list of `Operands`, @survive-operands.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    Main_Survival_Claim(&Operands, Main_Default_Margin);
    ```,
  ),
  caption: "Survive the list of operands",
) <survive-operands>

Retrieve the grammar tag of the `Operands` value, if it is has the pair tag (list), enter the `PAI_tag` case, as shown in @compile-name.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    tag = Grammar_Tag(Operands);
    switch (tag) {
        case NUL_tag:
            return Main_Error_Text(TFX_error_string,
                                   Main_Newprocess_String);

        case PAI_tag:
            operands = (PAI_type) Operands;
            name = operands->car;
            compiled_name = name;

            // Get the body
            body = operands->cdr;
            tag = Grammar_Tag(body);
    ```,
  ),
  caption: "",
) <compile-name>

The Operands, being of `EXP_type` is cast to `PAI_type`, which allows for the `car`& `cdr` operations.

By applying the `car` on the list, the `name` of the process is retrieved. Next, `cdr` the list to access the `body` of the newprocess. Validate the correct grammar tag again on the `body` value. Compilation of the body is shown in @compile-body.


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    switch (tag) {
      case NUL_tag:
          return Main_Error_Text(TFX_error_string,
                                  Main_While_String);

      case PAI_tag:
          // Enter nested scope for the body
          Dictionary_Enter_Nested_Scope();

          // Compile the body
          compiled_body = compile_sequence(body, Main_Newprocess_String);

          // Survive the body
          Main_Survival_Claim(&compiled_body, Main_Default_Margin);

          // Body size
          raw_body_size = Dictionary_Exit_Nested_Scope();
          body_size = make_NBR(raw_body_size);

          // Create compiled object of the newprocess
          compiled_newprocess = make_NEP(
              compiled_name,
              compiled_body,
              body_size
          );

          // Return the compiled newproccess
          return compiled_newprocess;
    }
    ```,
  ),
  caption: "",
) <compile-body>

On entering the case, call the dictionary enter nested scope. Proceed to compile the body as a sequence. Call the survival method on the compiled body.

Exit the dictionary nested scope, returning the number of declarations, create a number by using the `make_NBR` method.

All the compiled values are passed to the `make_NEP` grammar method, the compiled version of the newprocess is returned.


== Evaluation


Create the `nEP` evaluation frame, consisting of the name, body and body size.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    begin_frame(nEP);
      frame_slot(EXP, name);
      frame_slot(VEC, bod);
      frame_slot(NBR, bsz);
    end_frame(nEP);
    ```,
  ),
  caption: "",
) <evaluate-frame>

Proceed to evaluate the compilation information, as shown in @evaluate-prep.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    body = Newprocess->bod;
    body_size = Newprocess->bsz;
    name = Newprocess->name;

    // Push the new process on top of the stack
    thread_frame = (nEP_type) Thread_Push(Continue_newprocess_body, nEP_size);
    thread_frame->bod = body;
    thread_frame->bsz = body_size;
    thread_frame->name = name;

    // Make sure the body survives potential garbage collection
    survive_default(body);
    ```,
  ),
  caption: "Push NEP Frame on stack",
) <evaluate-prep>

Extract the values from the compiled object during the compilation process.

Proceed to push the continuation `Continue_newprocess_body` on the stack with size: `nEP_size`. Set the `body`, `body_size` and `name` from the compilation step to the `nEP` type thread object.

Proceed to apply survive on the `body` object.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    // Pop the process from the stack
    process_stack = Thread_Pop();
    process_stack->cnt = Main_Empty_Continuation;

    // Create coroutine with its process context
    coroutine = make_COR(name, body_size, body, process_stack);

    // Return the created coroutine
    return coroutine;
    ```,
  ),
  caption: "Evaluate - Make coroutine",
) <evaluate-make-cor>


The runtime object that is returned as the coroutine, is a procedure, named with the name & body of the process, as shown in @evaluate-make-coroutine.


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    // Create the 'coroutine' as a procedure
    // - Name of the procedure, process name
    // - Number of argument is zero
    // - Frame size, size of the frame of the newprocess body
    // - Body, is newprocess contents
    // - Env, is the thread context
    coroutine = make_PRC(Name, Main_Zero, Frame_Size, Body, (VEC_type) Context);

    // Survive the coroutine
    environment_size = Environment_Get_Environment_size();
    survive_dynamic(coroutine,
                    environment_size);

    // Return the coroutine procedure
    return coroutine;
    ```,
  ),
  caption: "Evaluate - Make coroutine",
) <evaluate-make-coroutine>

The name is passed to the procedure, number of arguments is zero, Frame_Size is the value of body_size, the body and lastly the Context, which is the process_stack value earlier.

After the coroutine is created, apply the `survive_dynamic` method on it.



#colbreak()
= `transfer` <transfer>

*TODO:* Continue here


The native transfer procedure starts off with making sure there are the correct number of values and of the correct type, as shown in @transfer-checks.


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    // Check the size of the vector, making sure
    // the expected number of arguments are present
    size = size_VEC(Vector);
    if (size != 2)
        return Main_Error_Text(EX2_error_string,
                               trs_string);

    // Extract the values from the input
    from_expr = Vector[1];
    to_expr = Vector[2];

    // Retrieve the grammar tags from the input expressions
    from_tag = Grammar_Tag(from_expr);
    to_tag = Grammar_Tag(to_expr);

    // Check if both are procedure grammar tags
    if (from_tag != PRC_tag)
        return Main_Error_Text("first argument must be a process", trs_string);
    if (to_tag != PRC_tag)
        return Main_Error_Text("second argument must be a process", trs_string);

    // Once tag is verified, cast to PRC type
    from_process = (PRC_type) from_expr;
    to_process = (PRC_type) to_expr;
    ```,
  ),
  caption: "Transfer - Checks",
) <transfer-checks>

The input vector, containing the process values is checked for correct value of 2 arguments.

Get the grammar tag from both expression and check if both are of the procedure type.

If both expression are of the `PRC_type`, cast the expression to said type.

Before switch to the target process context, a check is performed to validate that the target process has a valid context, as shown in @transfer-target-check.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    // Get the target process's context
    to_context = (CNT_type) to_process->env;

    // If target process has no context, we cannot continue
    if (to_context == NULL)
        return Main_Error_Text("target process has no context", trs_string);
    ```,
  ),
  caption: "Transfer - Target Process Context Check",
) <transfer-target-check>

Finally, the context swap can take place, as shown in @transfer-swap-context. The current context is saved by calling the `Thread_Keep()` method. The `saved_context` is given as value to the `env` field on the `from_process` runtime object.

With the current context saved, the current context is replaced by given `to_context` as a value to the `Thread_Replace` method.
Returning `Main_Unspecified` as return value.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    // Save the current process, by setting the env of the from process
    saved_context = Thread_Keep();
    from_process->env = (VEC_type) saved_context;

    // Replace the current thread
    Thread_Replace(to_context);

    // Will use the current thread on top of the stack
    return Main_Unspecified;
    ```,
  ),
  caption: "Transfer - Swap Context",
) <transfer-swap-context>

The `Thread_Replace` method is added to the `SlipThread.c` file, it replaces the private `Current_Thread` variable with the given `Thread` value.

#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```c
    NIL_type Thread_Replace(CNT_type Thread) {
      Current_thread = Thread;
    }
    ```,
  ),
  caption: "Transfer - Thread Replace",
) <transfer-thread-replace>


// #pagebreak()
// = Visualization


// #figure(
//   image("images/evaluate_newp.png"),
//   caption: "Newprocess - Stack & Context Visualization",
// ) <newprocess-visualization>


// #figure(
//   image("images/transfer.png"),
//   caption: "Transfer - Stack & Context Visualization",
// ) <transfer-visualization>



// *TODO:* Continue here



#colbreak()
= Experiments


The complete list of experiments can be found in section @appendix-experiments or as individual files in the slip directory.

The following list of experiments illustrating the coroutines are included:
+ `single-process.slip`
+ `ping-pong.slip`
+ `producer-consumer.slip`
+ `call-reply.slip`
+ `round-robin.slip`
+ `round-robin-bug.slip`

Majority of the examples have been slightly modified to work within the constraints of the current implementation.

Newprocesses can only be set by using the `set!` expression & references to function inside of a `define` function have been removed.

== Examples

The experiments: `ping-pong.slip`, `producer-consumer.slip` and `call-reply.slip` are the examples described in the project assignment.

== Extra(s)

The experiments: `round-robin.slip` & `round-robin-bug.slip` is one additional experiment, expanding the concept of the producer-consumer. Both versions work, but there is a bug in the matching file.

The value of the `name` variable passed to the `ProduceItem`, in the second producer, receives the value of the `item` just produced & consumed by the previous coroutines.

No fix for this problem has been found as of writing. This bug is avoided in the first file, by hardcoding the name of the producer.


#set page(columns: 1)
= Appendix <appendix>


== Experiments <appendix-experiments>


#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
      (define pong '())
      (define ping '())

      (set! ping (newprocess "ping"
                              (begin (define iter
                                        (lambda ()
                                          (begin (newline)
                                                (display "ping")
                                                (transfer ping pong)
                                                )))
                                      (iter))))

      (set! pong (newprocess "pong"
                            (begin (define iter
                                      (lambda ()
                                        (begin (newline)
                                              (display "pong")
                                              (transfer pong ping)
                                              )))
                                    (iter))))

      (transfer ping ping))
    ```,
  ),
  caption: "Ping Pong Example",
) <test-ping-ping>



#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
      (define Producer '())
      (define Consumer '())
      (define Buffer '())
      (define Full #f)
      (define item 0)

      (define ProduceItem
        (lambda ()
          (begin
            (set! item (+ item 1))
            (display "produce ")
            (display item)
            (newline)
            item)))

      (define ConsumeItem
        (lambda (item)
          (begin
            (display "consume ")
            (display item)
            (newline))))

      (set! Producer (newprocess
                      "Producer"
                      (begin
                        (define item 0)
                        (define loop
                          (lambda ()
                            (begin
                              (if (not Full)
                                  (begin
                                    (define item (ProduceItem))
                                    (set! Buffer item)
                                    (set! Full #t)
                                    (transfer Producer Consumer))
                                  (begin
                                    (display "waiting for consumer")
                                    (newline)
                                    (transfer Producer Consumer)))
                              )))
                        (loop))))
    ;; Continued on next page
    ```,
  ),
  caption: "Producer Consumer Part 1",
) <test-producer-consumer-1>




#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
      ;; See previous page
      (set! Consumer (newprocess
                      "Consumer"
                      (begin
                        (define item '())
                        (define loop
                          (lambda ()
                            (begin
                              (if Full
                                  (begin
                                    (set! item Buffer)
                                    (set! Full #f)
                                    (ConsumeItem item)
                                    (transfer Consumer Producer))
                                  (begin
                                    (display "waiting for producer")
                                    (newline)
                                    (transfer Consumer Producer)))
                              )))
                        (loop))))

      (transfer Producer Producer))
    ```,
  ),
  caption: "Producer Consumer Part 2",
) <test-producer-consumer-2>



#figure(
  zebraw(
    numbering: true,
    lang: false,
    ```rkt
    (begin
        (define spr '())
        (define msg 0)

        (define CallPartner
            (lambda (P)
                (display P)
                (newline)
                (set! spr (newprocess P (transfer spr spr)))))

        (define Reply
            (lambda (x)
                (begin
                    (display x)
                    (newline)
                    (set! msg x)
                    (transfer spr spr)
                    x)))

        (CallPartner "call")
        (Reply "hello")

        (display msg))
    ```,
  ),
  caption: "Call - Reply Example",
) <test-call-reply>


#bibliography("references.bib")
