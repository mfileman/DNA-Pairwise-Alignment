//
//  read_fasta.cpp
//  sequence_alignment
//
//  Created by madison on 10/13/20.
//

#include "read_fasta.hpp"
#include <iostream>
#include <fstream>



Fasta::Fasta(const char* file_path) {
    std::ifstream input(file_path);
    if (!input.good()) {
        std::cout << "Error opening: " << file_path << " Please enter valid file path." << std::endl;
        exit(1);
        return;
    }
    this->file_path = file_path;
}

char** Fasta::read() {
    char** sequences = new char*();
    std::string line;
    std::ifstream input(this->file_path);
    int i = 0;
    
    while(std::getline(input, line)) {
        if(line.empty() || line[0] == '>')
            continue;
        else {
            sequences[i] = (char*)calloc(line.length() + 1, sizeof(char)); // allocate memory
            strcpy(sequences[i], &line[0]);
            i++;
        }
    }
    input.close();
    return sequences;
}
