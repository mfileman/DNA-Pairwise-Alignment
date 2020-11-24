//
//  assignment_write.cpp
//  sequence_alignment
//
//  Created by madison on 10/13/20.
//

#include "assignment_write.hpp"
#include <iostream>
#include <fstream>
#include <filesystem>

void Assignment::assignment_write(const char* file_path, const char* text) {
    std::ofstream file;
    std::cout<<file_path<<std::endl;
    file.open(file_path);
    
    file << text;
    file.close();
}
