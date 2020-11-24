//
//  wrapper.cpp
//  sequence_alignment
//
//  Created by madison on 10/13/20.
//
#include <vector>
#include <iostream>
#include "read_fasta.hpp"
#include "assignment_write.hpp"


extern "C" char** read_fasta(const char* file) {
    return Fasta(file).read();
}

extern "C" void write_assignment(const char* file, const char* text) {
    Assignment::assignment_write(file, text);
};
