//
//  main.swift
//
//
//  Created by madison on 10/6/20.
//
import Foundation

/// Allows use of hard brackets to reference a character in a string
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

/// Stack struct not natively included in Swift
struct Stack<T> {
  fileprivate var array: [T] = []
    
    var isEmpty: Bool {
        return array.count <= 0
    }

  mutating func push(_ element: T) {
    array.append(element)
  }

  mutating func pop() -> T? {
    return array.popLast()
  }

  func peek() -> T? {
    return array.last
  }
}

/// Represents the potential directions during backtracking
enum Movement {
    case UP, LEFT, DIAGONAL
}

class Alignment {
    let s1, s2: String
    let score_matrix: [[Int]]
    let move_matrix: [[[Movement]]]
    var multiple_alignments: Bool
    
    init(s1 first: String, s2 second: String) {
        s1 = first
        s2 = second
        (score_matrix, move_matrix) = Alignment.calculate_matricies(s1, s2)
        multiple_alignments = false // after initialization, MUST call backtrack to get accurate assessment
    }
        
    func write_optimum_score(directory: String) {
        let str: String = String(self.score_matrix[s1.count][s2.count])
        write_assignment(directory + "assignment1.o1", str)
    }
    
    func write_multiple_alignments(directory: String) {
        let str = self.multiple_alignments ? "YES" : "NO"
        write_assignment(directory + "assignment1.o4", str)
    }
    
    func write_scoring_matrix(directory: String) {
        var str: String = ""
        
        for r in 0..<self.score_matrix.count {
            for c in 0..<self.score_matrix[r].count {
                str += String(self.score_matrix[r][c]) + " "
            }
            str += "\n"
        }
        write_assignment(directory + "assignment1.o2", str)
        
    }
    
    func write_optimum_alignment(directory: String) {
        let result = self.backtrack()
        let str = result.0 + "\n" + result.1
        write_assignment(directory + "assignment1.o3", str)
    }
    
    func write_all_alignments(directory: String) {
        var str = ""
        let result = self.all_backtracking()
        str += String(result.count) + "\n"
        
        for align in result {
            str += align.0 + "\n" + align.1 + "\n\n"
        }
        write_assignment(directory + "assignment1.o5", str)
        
    }
    
    func print_movement_matrix() {
        print("", terminator:"\t")
        for l in 0..<s2.count { print(s2[l], terminator:"\t")}; print()
        var tb = ""
        for r in 0..<self.move_matrix.count {
            print(s1[r], terminator:"\t")
            for c in 0..<self.move_matrix[r].count {
                tb += self.move_matrix[r][c].contains(Movement.DIAGONAL) ? "D" : ""
                tb += self.move_matrix[r][c].contains(Movement.LEFT) ? "L" : ""
                tb += self.move_matrix[r][c].contains(Movement.UP) ? "U" : ""
                print(tb, terminator:"\t")
                tb = ""
            }
            print()
        }
    }
    
    /// This function implements a DP solution to the optimum alignment of two strings question.
    /// It works by scoring the (sub)strings according to the scoring function:
        /// +2 for any match, -1 for any mismatch, and -2 for any match against a gap
    static func calculate_matricies(_ s1: String, _ s2: String) -> ([[Int]], [[[Movement]]]) {
        
        // INITIALIZE DP MATRICIES
        var score_matrix: [[Int]] = []
        var move_matrix: [[[Movement]]] = []
        
        for _ in 0...s1.count {
            score_matrix.append([Int](repeating: 0, count: s2.count+1)) // add a row with s2.count+1 size
        } // make first column 0's
        
        for _ in 0..<s1.count {
            move_matrix.append([[Movement]](repeating: [Movement](repeating: Movement.DIAGONAL, count: 0), count: s2.count)) // add a row with s2.count+1 size
        }
        
        // FILLING IN FIRST ROW AND COL WITH VALUES
        for j in 1..<score_matrix[0].count {
            score_matrix[0][j] = score_matrix[0][j-1]-2
        }

        for i in 1..<score_matrix.count {
            score_matrix[i][0] = score_matrix[i-1][0]-2
        }
        
        var left, top, diag: Int
        var max_location: [Movement]
        var against_gap: Bool

        for r in 1..<score_matrix.count {
            for c in 1..<score_matrix[r].count {
                left = score_matrix[r][c-1]
                top = score_matrix[r-1][c]
                diag = score_matrix[r-1][c-1]
                max_location = Alignment.surrounding_max_location(row: r, col: c, matrix: score_matrix)
                against_gap = (max_location.contains(Movement.LEFT) || max_location.contains(Movement.UP)) && (r != c)

                let l1 = s1[r-1]
                let l2 = s2[c-1]
                
                if ( l1 == l2 ) {
                    score_matrix[r][c] = diag + 2 // doesn't make sense to me, shouldn't we maximize?
                    move_matrix[r-1][c-1].append(Movement.DIAGONAL)
                    if ( against_gap && (((left - score_matrix[r][c]) == 2) || (top - score_matrix[r][c]) == 2) ) {
                        move_matrix[r-1][c-1].append(contentsOf: max_location)
                    }
                }
                else if ( against_gap ) {
                    score_matrix[r][c] = max(left, top, diag) - 2
                    move_matrix[r-1][c-1].append(contentsOf: max_location)
                }
                else if ( l1 != l2 ) { // mismatch
                    score_matrix[r][c] = max(left, top, diag) -  1
                    move_matrix[r-1][c-1].append(Movement.DIAGONAL)
                    
                }
            }
        }
        return (score_matrix, move_matrix)
    }

    
    static func surrounding_max_location(row r: Int, col c: Int, matrix: [[Int]]) -> [Movement] {
        let top = matrix[r-1][c]
        let left = matrix[r][c-1]
        let diag = matrix[r-1][c-1]
        var returned: [Movement] = []
        
        let surrounding_max = max(top, left, diag)
        if surrounding_max == diag { returned.append(Movement.DIAGONAL) }
        if surrounding_max == left { returned.append(Movement.LEFT) }
        if surrounding_max == top { returned.append(Movement.UP) }
        return returned
    }
    
    func backtrack() -> (String, String) {
        var r = self.move_matrix.count-1
        var c = self.move_matrix[r].count-1
        var current: [Movement]
        var alignment = ("", "")
    
        while( r >= 0 && c >= 0 ) {
            current = self.move_matrix[r][c]
            if ( current.count > 1 ) { self.multiple_alignments = true }
            
            switch current[0] {
                case .UP:
                    alignment.0.insert(self.s1[r], at: alignment.0.startIndex)
                    alignment.1.insert("-", at: alignment.1.startIndex)
                    r-=1
                case .DIAGONAL:
                    alignment.0.insert(self.s1[r], at: alignment.0.startIndex)
                    alignment.1.insert(self.s2[c], at: alignment.1.startIndex)
                    r-=1
                    c-=1
                case .LEFT:
                    alignment.0.insert("-", at: alignment.0.startIndex)
                    alignment.1.insert(self.s2[c], at: alignment.1.startIndex)
                    c-=1
            }
        }
        return alignment
    }
    
    
    func all_backtracking() -> [(String, String)] {
        var align: [(String, String)] = []
        DFS(alignments: &align)
        return align
    }
    
    private func DFS(alignments: inout [(String, String)]) {
        
        var r = self.move_matrix.count-1
        var c = self.move_matrix[r].count-1
        var visited: [[Int]: ([Movement], (String, String))] = [:] // directions taken & string alignment at r,c along an optimum path
        var s: Stack<[Int]> = Stack<[Int]>() // for DFS, queue of [r,c] pairs (tuple's arent hashable :/ )
        
        var movement_options: [Movement] // Movement options at (r,c)
        var previous_alignments: (String, String) = ("","") // alignments @ the previous position during the construction of optimum alignments
        var new_alignments: (String, String) // alignments (to be constructed) at position r,c in the move matrix

        // filling up stack for the first time
        while( r >= 0 && c >= 0 ) {
            movement_options = self.move_matrix[r][c]
            new_alignments = update_alignments(r: r, c: c, direction: movement_options[0], previous_alignments: previous_alignments)
            visited[[r,c]] = ( [movement_options[0]] , new_alignments ) // mark r,c as visited and have taken movement_options[0] direction
            s.push([r,c]) // add r,c location to path being built
            
            previous_alignments = new_alignments // holds onto current alignments for next iteration
            if (r == -1 || c == -1) { break } // no where to move from 0,0 : for next lines, do not take direction at 0,0
            take_direction(r: &r, c: &c, direction: move_matrix[r][c][0]) // EDITS r & c : takes the direction at move_matrix[r][c][0]
        }
        
        
        // start back tracking
        var r_c : [Int] // [r,c] pair corresponding to location in move_matrix
        var movements_taken: [Movement]
        while( !s.isEmpty ) {
            r_c = s.pop() ?? [-1, -1]

            // copy r_c optional to r & c (non optionals)
            if ( r_c[0] >= 0 && r_c[0] <= self.move_matrix.count-1 && r_c[1] >= 0 && r_c[1] <= self.move_matrix[0].count-1){
                r = r_c[0]
                c = r_c[1]
            } else { print("during DFS backtracking, popped out of move_matrix bounds r,c pair"); exit(1) } // ensure we are within the bounds of the move matrix

            movement_options = self.move_matrix[r][c]
            movements_taken = visited[r_c]?.0 ?? []
            if ( movements_taken.count != movement_options.count ) { // not all directions have been taken
                find_alternative_alignment_path(s: &s, visited: &visited, r_c: r_c)
                
            }
            else if ( r == 0 && c == 0 ) { // found another path to the beginning i.e another alignment
                alignments.append(visited[r_c]!.1)
            }
        }
    }
    
    private func find_alternative_alignment_path(s: inout Stack<[Int]>, visited: inout [[Int]: ([Movement], (String, String))], r_c: [Int]) {
        // this pushes onto the stack & takes the next (previously not taken) direction at the current r,c
        var r = r_c[0]
        var c = r_c[1]
        var movement_options: [Movement]
        var movements_taken: [Movement]
        var previous_rc: [Int]
        var previous_alignments: (String, String)

        while( r >= 0 && c >= 0 ) {
            movement_options = self.move_matrix[r][c]
            previous_rc = s.peek() ?? [self.move_matrix.count, self.move_matrix[0].count]
            previous_alignments = visited[previous_rc]?.1 ?? ("","")
            
            // MOVEMENTS TAKEN / setup if visiting new position in move matrix
            if ( visited[[r,c]] != nil ) { movements_taken = visited[[r,c]]!.0 } // if we've already taken some direction at this position
            else { // if we havent already visited this position
                let alignments: (String, String) = update_alignments(r: r, c: c, direction: movement_options[0], previous_alignments: previous_alignments)
                visited[[r,c]] = ( [movement_options[0]] , alignments )
                movements_taken = visited[[r,c]]!.0
            }
            s.push([r,c])
            
            // UPDATE STATE OF PATH
            if ( movement_options.count == movements_taken.count && movement_options.count == 1) {
                visited[[r,c]]?.1 = update_alignments(r: r, c: c, direction: movement_options[0], previous_alignments: previous_alignments )
                take_direction(r: &r, c: &c, direction: movement_options[0])
            }
            else if ( movement_options.count > 1 && !movements_taken.contains(movement_options[1]) ) { // if hasnt taken moveoption1
                // reflect movement option 1 has been taken & update the string alignments at that point
                visited[[r,c]]?.0.append(movement_options[1])
                visited[[r,c]]?.1 = update_alignments(r: r, c: c, direction: movement_options[1], previous_alignments: previous_alignments )

                // update r & c
                take_direction(r: &r, c: &c, direction: movement_options[1])

            }
            else if ( movement_options.count > 2 && !movements_taken.contains(movement_options[2]) ) { // hasnt taken moveoption2
                movements_taken.append(self.move_matrix[r][c][2])
                // reflect movement option 2 has been taken & update the string alignments at that point
                visited[[r,c]]?.0.append(movement_options[2])
                visited[[r,c]]?.1 = update_alignments(r: r, c: c, direction: movement_options[2], previous_alignments: previous_alignments )
                
                // update r & c
                take_direction(r: &r, c: &c, direction: movement_options[2])
            }
        }
    }
    
    private func take_direction(r: inout Int, c: inout Int, direction: Movement) {
        switch direction {
            case .UP:
                r-=1
            case .DIAGONAL:
                r-=1
                c-=1
            case .LEFT:
                c-=1
        }
    }
    
    private func update_alignments(r: Int, c: Int, direction: Movement, previous_alignments: (String, String) ) -> (String, String) {
        let l1: Character
        let l2: Character
        
        if ( r >= 0 ) { l1 = self.s1[r] } else { return ("","") }
        if ( c >= 0 ) { l2 = self.s2[c] } else { return ("","") }
        
        var returned: (String, String) = ("","")
        switch direction {
        case .LEFT:
            returned.0 = "-" + previous_alignments.0
            returned.1 = String(l2) + previous_alignments.1
            break
        case .UP:
            returned.0 = String(l1) + previous_alignments.0
            returned.1 = "-" + previous_alignments.1
            break
        case .DIAGONAL:
            returned.0 = String(l1) + previous_alignments.0
            returned.1 = String(l2) + previous_alignments.1
            break
        }
        return returned
    }
}


// MAIN
print("please enter a file path to read from: ", terminator: " ")

if let file = readLine() {
    let file_c_str = (file as NSString).utf8String!
    let dna: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> = read_fasta(file_c_str) // initialized char**

    guard let s1 = dna[0] else { print("error in reading dna strings"); exit(1) }
    guard let s2 = dna[1] else { print("error in reading dna strings"); exit(1) }
    dna.deallocate()

    let dna1 = String(cString: s1) // copies
    let dna2 = String(cString: s2) // copies

    let a = Alignment(s1: dna1, s2: dna2)
    print("please enter a directory path to write to: ", terminator: " ")
    if let dir = readLine() {
        a.write_optimum_score(directory: dir) // part 1
        a.write_scoring_matrix(directory: dir) // part 2
        a.write_optimum_alignment(directory: dir) // part 3
        a.write_multiple_alignments(directory: dir) // part 4
        if a.multiple_alignments { a.write_all_alignments(directory: dir) }
    }
}
