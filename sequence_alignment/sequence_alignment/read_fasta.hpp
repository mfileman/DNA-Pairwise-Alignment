//
//  read_fasta.hpp
//  sequence_alignment
//
//  Created by madison on 10/13/20.
//

#ifndef read_fasta_hpp
#define read_fasta_hpp

#include <string>
#include <vector>

class Fasta
{
    public:
        Fasta(const char* file_path);
        char** read();
    private:
        const char* file_path;
};

#endif /* read_fasta_hpp */
