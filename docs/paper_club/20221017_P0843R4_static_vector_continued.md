# P0843R4, part 2

static_vector, continued

## About

**Paper:** [P0843r4](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p0843r4.html)

**Date:** 2022-10-17

**Author:** David Friberg (not verbatim, best effort).

**Attendees:**

- David Friberg (DF)
- Dave Brown (DB)
- Jonas Persson (JP)
- Björn Andersson (BA)
- Bengt Gustafsson (BG)

## Minutes

- We focused our discussion around Bengt's P2667R0 proposal, which would be a replacement to P0843R5
  - Will be presented at Kona
  - Author of P0843R5 initially gave feedback that P2667 was a good idea, but has since seems to have stopped communication
- We all liked the idea of leveraging std::vector for static_vector , but focused discussion on some of the challenges:
- Challenge that both proposals face:
  - Checked vs unchecked discussion: we decided not to focus more on this
- Challenges that P2667R0 faces that the simpler (smaller impact due to freestanding header) solution of P0843 **does not face**:
  - **A much larger change**, may require several papers to focus on the individual new features needed to make this possible
  - Leverage a new namespace, std::allocator_info for facilitating growing non-class bound allocator-like traits
    - ... avoiding falling into the trap of std::allocator_traits which cannot be extended due to the breaking impact of such a change
    - New allocator traits
    - Several changes to how std::vector is implemented, to facilitate std::static_vector as an alias template to a partial specialization set of the former
  - **Not a freestanding header:** the original paper focused on freestanding header as a key feature to facilitate embedded:
    - Allows to have no exceptions inherent to the container itself, only conditional non-noexceptness based on the wrapped type
      - ... meaning no try, catch, throw statements in the free-standing header itself
      - ... facilitating -fno-except
      - However it still seems unclear in the original proposal whether mutating ops that exceed capacity should throw or not (LEWG suggested that this should be UB to allow the implementor freedom)
      - std::vector currently do not apply conditional noexcept on push_back, which is something we would like to make conditional to facilitate Bengt's proposal
      - However this is a breaking change (now ABI break, as far as we can see) due to mangling where noexcept, including expression in noexcept(expression), is part of mangling
    - Not bringing in allocator-specific dependencies that may not be suitable in an embedded environment
      - Currently <vector> depends on std::allocator from <memory>; ideally std::vector would get most of its implementation via implementation inheritance from std::basic_vector , living in a separate header, and bring in the dep to <memory> only in the std::vector-specific header, whereas std::static_vector could depend only on <basic_vector>,
    - ... but this would be a ABI-breaking change.
- We had a lot of good discussions and will try to schedule a follow-up ASAP, ideally having another meeting or two before Kona

(In the end we never had time to meet again before Kona)

