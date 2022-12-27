# P0843R4

static_vector

## About

**Paper:** [P0843r4](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p0843r4.html)

**Date:** 2022-07-05

**Author:** David Friberg (not verbatim, best effort).

**Attendees:**

- David Friberg (DF)
- Dave Brown (DB)
- Jonas Persson (JP)
- Oliver Lee (OL)
- Björn Andersson (BA)
- Arvid Norberg (AN)
- Johan Söderbäck (JS)

## Minutes

- DB: relevance in embedded space; issues with dynamic memory. A better abstraction than tracking an array with a size.
- AN: Do you have experience with Boost's static vector impl?
- DB: (in safety critical typically 3rd party libs are banned, so no boost) I've used boost and some other 3rd party guy, but some time ago
- AN: In my domain we typically don't (need to) use static_vector
  - We do have a non-embedded project though where we use a fixed-size container (C array) with the risks that may come with it; static_vector would be better here
- OL: General safety-critical frustration with writing back ports as opposed to using e.g. boost
  - One key question is what to do when capacity is exceeded - exceptions may not fit for the particular domain where static_vector is particularly useful (embedded)
  - Policies and contracts - variance from rest of stdlib
- DF: Discussions in SSRG - a lot of emphasis was placed on drop-in replacement for std::vector
  - Boost's static vector is a bit simpler (uninitialized buffer: non-default constructible types, not full constexpr support where you could have it)
- AN: I think the most interesting topic is "what do we do when exceeding capacity"?
  - I really don't like the name static_ here
- DF: Big misconception in "regular C++ dev" community → dynamic == heap → this naming may add to the confusion about what dynamic memory means.
- BA: I echo Dave's comments: but also relevant outside of embedded (/safety-critical):
  - Needn't worry about reserve() and so on
  - Regarding naming: proposal mentions names (vector_n was a close call)
- JS: My domain is medical; we have our own static_vector-ish which is named Static: nice to have one in the standard lib
- AN: What do you do in your domain when exceeding capacity:
  - JS: terminate the program
  - DF: contracts (assertion test drivers for death testing, std::abort-ish assert "possibly" active in release)
- Zooming in on **Exception safety (and dynamic memory in "a new safety critical world"):**
  - AN: Reflection from LLVM mailing list:
    - "name push_back kind of implies wide contracts (... implies exception), so problematic to give this name a narrow contract"
    - "can't there be two push_back, one for each contract version?"
  - (DF: relevant paper: https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1656r2.html)
  - DF: old boost thread on static vector had a heavy discussion on the names "unchecked_push_back", "checked_push_back" and which one of them that ought to be default and so on (some even proposed there should be no "push_back", only the more descriptive ones)
  - OL: there's some ongoing community-splitting discussions about opening up for two different types of error handling (within the same type)
  - AN: Imo narrow contracts is not error handling (due to UB)
  - BA: Revision log mentioned checked at() was removed, why?
  - AN: Purpose of the type is to be stand-alone/free-standing, so it can't throw exceptions
  - DB: The proposal mentions that throwing checked_xxx methods could be provided in backwards-compatible way
  - DF: Safety-critical used to be == embedded, but nowadays we move to POSIX systems, and we even remove hard realtime constraint for a majority of our code
    - This means we are removing the #1 reason for banning dynamic memory allocations in this domain
  - OL: My experience is that this is not going away everywhere
  - DF: Agreed - what we see however is that we now allow deviations, even
  - BA: We also see similar timing constraints within e.g. trading
  - AN: I have the same experience - we allocated everything in .bss (or .data?)
  - DF: Did you feel any pain w.r.t. using these static-init'd objects?
  - AN: Somewhat, weird control flow, hard to test.
  - DF: Dave, what do you think old-safety-critical domain should start reconsidering, when we've left hard embedded domain?
  - DB: PMRs
  - DF: Anyone experienced with PMRs?
  - AN: No, but a question
    - Paper mentions "A static_vector can also be poorly emulated by using a custom allocator, like for example Howard Hinnant's stack_alloc [4], on top of std::vector" - what do they mean?
  - DB: Painful memory pooling
  - OL: You tie the lifetime of you vector to your memory resource; general annoyance when using custom allocators
  - AN: I was under the impression that How. Hin. allocator actually contained the memory
  - JS: No, the memory is in an arena somewhere. In my code: arena allocator and std containers - messy
  - JS: IIRC there are some constraints that bans placing the memory in the allocators
  - DF: One pro for allocators and con for static_vector is that using a STL implementation may not offer as much support for valgrind
  - AN: I thought address sanitizer may have replaced valgrind, but we need to instrument the compiler with some hooks/macros (like for valgrind)
  - BA: For trivially destructible objects (no op) it may be hard for tools to track that an object's lifetime is over
  - OL: you still have a dtor call
  - BA: True, build for tools
  - AN: UBsan is the one that typically finds type errors (bad aliasing / accessing dtor objects)
  - AN: @safety critical: when you run into a precondition violation, which is typically UB, do you always check it anyway in release, or is UB OK?
  - DF: Not as strict, UB sometimes, checked sometimes (e.g. ZEN_ASSERT vs ZEN_DEBUG_ASSERT based on cost). E.g. aviation industry extremely safety-critical (a bug could lead to 50% of global death toll over a year), automotive industry growing faster than the safety standards for it (1.5 mil deaths, 55 mil injuries per year, a bug could lead to <10 deaths before discovered)
  - OL: I would love to see a tag or something that can be passed to stl API's to choose how a contract violations should be handled (exceptions, herbception, even change an API between a wide and narrow contract). I don't think e.g. static_vector should be a drop-in replacement.
  - BA: To be fair there are probably many places where static_vector is a good replacement for std::vector
  - OL: Yes (small_vector)
  - BA: In Chapter 3 they refer to some other implementation:
    - " Boost.Container [1], EASTL [2], and Folly [3]"
    - EASTL seems to be able to turn into static_vector
    - Would it make sense to extend this proposal to make static_vector a subset of EASTL?
  - AN: My feeling is that the root problem remains; you still end up altering the contract for push_back. I would guess folly etc use small buffer optimization with the ability to grow into the heap (compare with SSO in std::string).
- Wrapping up: Let's have a follow meeting, a nice discussion.

## Actions

- DF to organize a follow-up.
