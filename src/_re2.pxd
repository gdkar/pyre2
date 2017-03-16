from posix.unistd cimport *
from posix.stdio cimport *
from libc.stdint cimport *
from libcpp cimport bool
cdef extern from *:
    ctypedef char* const_char_ptr "const char*"

from libcpp.string cimport string as stl_string
cdef extern from "<string>" namespace "std" nogil:

    ctypedef stl_string cpp_string "std::string"
    ctypedef stl_string const_string "const std::string"


from libcpp.map cimport map as stl_map
cdef extern from "<map>" namespace "std" nogil:
    ctypedef stl_map[stl_string,int] stringintmap "std::map<std::string,int>"
    ctypedef stl_map[stl_string,int] const_stringintmap "const std::map<std::string,int>"

    ctypedef stl_map[stl_string,int].iterator stringintmapiterator "std::map<std::string,int>::const_iterator"

cdef extern from "Python.h":
    int PyObject_AsCharBuffer(object, const_char_ptr *, Py_ssize_t *)
    char * PyString_AS_STRING(object)

cdef extern from "re2/stringpiece.h" namespace "re2":
    cdef cppclass StringPiece:
        StringPiece()
        StringPiece(const_string &)
        StringPiece(const_char_ptr)
        StringPiece(const_char_ptr, size_t)

        const_char_ptr data()
        size_t copy(char * buf, size_t n, size_t pos)
        size_t length()
        size_t size()
        bool   empty()
        stl_string as_string()

    ctypedef StringPiece const_StringPiece "const StringPiece"
 
cdef extern from "re2/re2.h" namespace "re2":
    cdef enum Anchor:
        UNANCHORED "RE2::UNANCHORED"
        ANCHOR_START "RE2::ANCHOR_START"
        ANCHOR_BOTH "RE2::ANCHOR_BOTH"

    ctypedef Anchor re2_Anchor "RE2::Anchor"

    cdef enum ErrorCode:
        NoError "RE2::NoError"
        ErrorInternal "RE2::ErrorInternal"
        # Parse errors
        ErrorBadEscape "RE2::ErrorBadEscape"          # bad escape sequence
        ErrorBadCharClass "RE2::ErrorBadCharClass"       # bad character class
        ErrorBadCharRange "RE2::ErrorBadCharRange"       # bad character class range
        ErrorMissingBracket "RE2::ErrorMissingBracket"     # missing closing ]
        ErrorMissingParen   "RE2::ErrorMissingParen"       # missing closing )
        ErrorTrailingBackslash "RE2::ErrorTrailingBackslash"  # trailing \ at end of regexp
        ErrorRepeatArgument "RE2::ErrorRepeatArgument"     # repeat argument missing, e.g. "*"
        ErrorRepeatSize "RE2::ErrorRepeatSize"         # bad repetition argument
        ErrorRepeatOp "RE2::ErrorRepeatOp"           # bad repetition operator
        ErrorBadPerlOp "RE2::ErrorBadPerlOp"          # bad perl operator
        ErrorBadUTF8 "RE2::ErrorBadUTF8"            # invalid UTF-8 in regexp
        ErrorBadNamedCapture "RE2::ErrorBadNamedCapture"    # bad named capture group
        ErrorPatternTooLarge "RE2::ErrorPatternTooLarge"    # pattern too large (compile failed)

    cdef enum Encoding:
        EncodingUTF8 "RE2::Options::EncodingUTF8"
        EncodingLatin1 "RE2::Options::EncodingLatin1"

    ctypedef Encoding re2_Encoding "RE2::Options::Encoding"

    cdef cppclass Options "RE2::Options":
        Options()
        void set_posix_syntax(int b)
        void set_longest_match(int b)
        void set_log_errors(int b)
        void set_max_mem(int m)
        void set_literal(int b)
        void set_never_nl(int b)
        void set_case_sensitive(int b)
        void set_perl_classes(int b)
        void set_word_boundary(int b)
        void set_one_line(int b)
        int case_sensitive()
        void set_encoding(re2_Encoding encoding)

    ctypedef Options const_Options "const RE2::Options"

    cdef cppclass RE2:
        RE2(const_StringPiece pattern, Options option) nogil
        RE2(const_StringPiece pattern) nogil
        int Match(const_StringPiece text, int startpos, int endpos,
                  Anchor anchor, StringPiece * match, int nmatch) nogil
        int NumberOfCapturingGroups()
        int ok()
        const_string pattern()
        cpp_string error()
        ErrorCode error_code()
        const_stringintmap& NamedCapturingGroups()

    ctypedef RE2 const_RE2 "const RE2"

#cdef extern from "<utility>" namespace "std" nogil:
#    T *addressof[T](T& arg)
#    const T *addressof[T](const T& arg)
# This header is used for ways to hack^Wbypass the cython
# issues.
cdef extern from "_re2macros.h" namespace "cymacros" nogil:
    # This fixes the bug Cython #548 whereby reference returns
    # cannot be addressed, due to it not being an l-value
    T *addressof[T](T&)

cdef extern from "_re2macros.h":
    StringPiece * new_StringPiece_array(int) nogil
    void delete_StringPiece_array(StringPiece* ptr)

    char * as_char(const_char_ptr)

    # This fixes the bug whereby namespaces are causing
    # cython to just break for Cpp arguments.
    int pattern_Replace(cpp_string *str,
                        const_RE2 pattern,
                        const_StringPiece rewrite)
    int pattern_GlobalReplace(cpp_string *str,
                              const_RE2 pattern,
                              const_StringPiece rewrite)
from libcpp.cast cimport *
cdef inline char * as_char_ptr(const_char_ptr ptr):
    return <char*>(ptr)
