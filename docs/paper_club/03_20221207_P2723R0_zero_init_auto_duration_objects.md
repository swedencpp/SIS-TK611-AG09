# 2022-12-07: SIS/TK 611/AG09 - Paper club #3 - [P2723R0] Zero-initialize objects of automatic storage duration

**Paper:** https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p2723r0.html

**Attendees:**

- David Friberg (DF)
- Dave Brown (DB)
- Björn Andersson (BP)
- Jonas Persson (JP)
- Arvid Norberg (AN)
- Daniel Eriksson (DE)
- Bengt Gustafsson (BG)
- Harald Achitz (HA)
- Oliver Lee (OL)

## Agenda

- Around the table - reflections on the paper
- Launch the deeper discussions

## Other/related references

DF: Some related references before we start:

- JF on the ext, on the direction of R1 of the paper: https://lists.isocpp.org/ext/2022/11/20242.php
  - Highlights:
    - Will retain focus on implicit initialization, but will not focus on semantic guarantees of what will happen when reading such values, even though "the read is OK" after P2327.
    - Why not also aim for semantics guarantees?
        - Different views on whether its even viable at all, or viable yet.
        - ... facilitate the easier-to-pass paper and work on semantic guarantees separately
- Tom Honermann has a related proposal: https://lists.isocpp.org/ext/2022/11/20280.php
  - [isocpp-ext] Posioned values: A feature and specification mechanism to aid diagnosis of implicitly initialized variables
  - DF: None of us have read this - read this before follow-up paper club.

## Minutes

- Around the table:
  - AN:
    - Lots of discussion on ext, which I read before I read the paper
      - Most concerns: "bug hiding" - want to be able to diagnose uninitialized values
      - Seems that you can still address this: catch the mistake but make it lenient (until fixed)
  - BG:
    - Also has a concern for "bug hiding" - could it be better to use "bad value" rather than zero?
        - ... for pointers zero is reasonable for trapping
            - MSVC already do this in debug builds
            - Would be interesting to measure performance when adding flags for traps
        - ... for others, risk of bug hiding (or even giving root access - access given in the example)
  - OL:
    - Haven't read the mailing list
        - (DF: it's a lot of noise)
    - Can't decide whether paper is good/bad
    - Regarding AN's comment: you could avoid these bugs in the first place
  - BA:
    - Imo benefits outweights the downsides at this point
    - Haven't read the mailing list discussions
  - JP:
    - Have have internal discussions - lots of opinions (bare metal compiler vendor)
      - Mostly run on bare metal - most bugs relating to safety
        - We typically pay for what we don't use
            - (DF: ~the performance metrics shown in the paper may not be representative for bare metal?)
        - Customers may not think this feature is worth it
            - ... meaning we may have to add a new compiler flag
    - Fear that not only "bug-hiding" will occur, but also enforcing bad patterns in C++ developers that unitialized vars are bad
    - Also the question of how to approach this in C?
      - ... given that many customers are migrating from C to C++
    - Smaller embedded targets:
      - You get hardware trap/trigger when you read to memory that has not been written to yet
        - ... You could potentially loose this if you write to bug-non-initialized auto vars
    - If this really happens → would be preferred if this is more uniform so that it will be value initialization and not special (zero but not value) for auto variables
      - BA: also initializes padded bits
  - DE:
    - Sounds generally like a good idea, mostly listening in today to hear more opinions
  - DB:
    - The paper in general does a good job to motivate its existence
      - Lots of articles pointing out security bugs/vulnerabilities due to uninitalized data
      - Trying to solved "undisciplined code writing" via safe-guards of the language
      - Regarding \[[uninitialized]] attribute: can become noisy but maybe it's a good thing
    - Overall: good impression
  - DF:
    - Not much to add: positive, mostly worried about bug-hiding
    - Unfortunate that the paper doesn't argue around the safety aspects
        - SSRG - very positive, most of the discussion is around how many discussion there are around it
            - ... maybe only the security guys pitching in?
    - AN: An option that I pointed out (regarding handling bug-hiding)
      - "In debug, you are allowed to trap - in release mode you shall not - zero-init it there"
      - Comment to BG:
        - Paper discusses intializes other than zero values, but describes a larger degradation to performance
      - Question to JP:
        - Are you suggesting that embedded systems are more susceptible to performance degradations than what is highlighted in the paper? (~0.5% for time and size)
        - JP: We (our compiler) do not currently have this
          - In general: our customers are very concerned with speed and size - for smaller targets particularly the latter.
            - If we ship versions that degrade performance, customer unhappiness
            - Some customers even inspect assembly difference between versions
        - DF: The paper mentions that "we couldn't do this before, but we can now, due to compiler optimizations" - are they omitting  "smaller"/non-x86 degradations?
        - BG: Even a degradation of 0.5% could be very costly for large coorparations
          - DF: The paper mentions that sometimes performance increased
            - JP: This are likely missed opportunities that could arguably be optimized without actually zero-initializing
                - ... Potentially bugs triggering optimizations
            - AN: They mention particularly data dependencies as allowing certain kind of optimizations (early instruction actions)
- Zooming in on **bug-hiding**:
  - AN: There seems to be no strong consensus regarding hiding bugs
  - HA: What about compiler errors on uninitalized values?
    - Discussed in the paper: current warning families are not so stable and it would end up in the "too complex rules to put on implementors unless they are very simple"
  - AN: My feeling is that this is not a tool to find bugs, but rather to avoid vulnerabilites in actual production code
    - Meaning it doesn't really move the needle on safety, just on security
    - DF: The paper discusses research on security but none on safety
    - BA: Makes it more deterministic, so maybe you can find a bug faster
      - DF: If it is more deterministic, it could also become a systematic fault that you don't find
  - HA: I was surprised by the claim that the uninitalized warning set was unstable - can I not trust this warning set?
    - BG: We may be talking about a different case: the warning family should work fine for things that can be determined on compiler time (e.g. analyzing possible paths around if-else branch, making sure there is no path "this will never have been initialized here")
      - ... what this paper tries to handle are families of bugs that can rarely be caught by compile-time analysis
    - HA: Even if you have something uninitialized, then a condition, then it is still uninitialized in the first place, whereas the paper talks about always initializing it in the first place
      - JP: Semantically the value is still considered uninitialized, but it should be zero (security concerns)
      - OL: Isn't this a question of semantics, intent from the user?
        - DF: The paper (or discussion around it) focuses on that it is not focusing at all on semantics, only on the unfortunate result of when users write code with undefined behaviour
    - HA: I think we should be able to trust our compilers
      - "You have to initialize, of you have annotate that you mean you cannot uninitialize"
        - DF: This would be a breaking change, if made a requirement from the standard
            - ... the standard does not make vendor recommendations
    - HA: Ideally one could add a family of incrementally increasing warnings for newer code, whilst old code falls under older code
      - ... but hard to implement in practice
    - HA: Making the old code suddenly have zero values instead of random/UB values could arguably also be breaking changes
      - ... as shown by JP example above
      - I would favor making sure the compiler becomes better and better at analyzing new code
    - BG: A problem is that we will keep making bugs
      - ... when refactoring old code, risk of blindly adding the uninit attribute
    - AN: Not entirely fair, would be compared as using unsafe/unitialized API/functionality in Rust
    - HA: In general, trying to make existing code with bugs "safer" by adding a more deterministical (zero instead of "meta-random"): is this really always an improvement?
      - AN: Hard to argue that UB is better than anything else
    - DF: What do you think HA about this paper specifically, addressing this kind of issue in the standard, vs addressing it via implementors (as standard does not give implementors advice)
      - HA: Maybe this is the root problem: to unify tooling and user experience, why can the standard not give advice to vendors as opposed to being entirely disparate towards it?
    - AN: From the paper:
      - "Another alternative is to guarantee that accessing uninitialized values is implementation-defined behavior, where implementations must choose to either, on a per-value basis:
        - zero-initialize; or
        - trap (we can argue separately as to whether "trap" is immediate termination, Itanium [NaT], or std::terminate or something else)."
    - BG: Maybe we should focus on improving the situation of ever wanting to create variables that we don't initialize immediately
      - AN: Structured bindings helper us here to avoid out parameters when having multiple returns
      - BG: And I think pattern matching can make things even better
        - (... we also have immediately invoked lambdas, ternary ops, ...)
      - BG: Maybe there are even more syntactic structures that could allow this
        - ... although this would not help us with old code
    - DF: Time is running out: I will book a follow up meeting to continue, where we can also discuss Honermann's paper
    - BA: I hope I can speak for all of us that we these discussions are very interesting, but I wish we could have a higher cadence
      - Could we just set a fixed date for paper clubs?
    - Everyone: sounds like a good idea, but we should discuss what time to have these
      - HA: some groups rotate, so some rotation may be a good idea.
      - Action: bring to slack to vote/discuss on cadence and time slots

## Actions

- DF: Make sure everyone have access to Honermann's "paper" (paper idea?)
- Everyone: read this before next paper club
