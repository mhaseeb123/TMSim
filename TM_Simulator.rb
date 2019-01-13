# Date: 11/30/2017
# Class: CS-5800 | Fall-2017
# Project: Turing Machine Simulator
# Author: Muhammad Haseeb

require 'pp'
require 'matrix'

#######################################################
#
# Class: TuringMachine
#
#######################################################
class TuringMachine
  # Allow access to the class variables
  attr_accessor :Q, :E, :S, :I, :F, :valid_machine

  ######################################################
  #
  # Method: initialize
  # Description: Initializes a new TuringMachine object
  # @input: File containing machine description
  #
  ######################################################
  def initialize machineFile
    @valid_machine = true
    @temo = machineFile
    return if (!@temo)

    status = 0
    @machineFile = machineFile

    if (!@machineFile || @machineFile == "")
      $stderr.puts "\n\n==== ERROR: No Turing Machine file provided at the input. ===="
      status = -3
    end

    if (status == 0 && !File.exist?(@machineFile))
      $stderr.puts "\n\n==== ERROR: The file #{@machineFile} does not exist. ====\n\n"
      status = -3
    end

    # If input file provided, read the DFA from it
    if (status == 0)
      status = readMachine(@machineFile)
      # Check the status and throw error in case of failure
      if (status != 0)
        $stderr.puts "ERROR: The method \"readMachine\" Failed", "ERROR CODE: #{status}"
      end
    end

    # Initialize the Transiition Table from the input file
    if (status == 0)
      status = readTMtable(@machineFile)
      # Check the status and throw error in case of failure
      if (status != 0)
        $stderr.puts "ERROR: The method \"readTMtable\" Failed", "ERROR CODE: #{status}"
      end
    end
    @valid_machine = false if (status != 0)
  end

  ######################################################
  #
  # Method: readTMtable
  # Description: Read and initialize the transition table
  #              of the Turing Machine
  # @input: File containing machine description
  #
  ######################################################
  def readTMtable machineFile
    status = 0
    @machineFile = machineFile
    @done = false
    @S = Matrix[]

    fh = File.open(@machineFile, "r")
    fh.each_line do |line|

      # Read the machine type to be DFA
      if line.start_with? "Machine"
        var = line.chomp!
        # Reference # 08
        if (var.partition("=").at(2) != @machineType)
          status = -2
          break
        end
      end

      # Ref: 01
      if (@done == false && !(line.start_with? "S"))
        next
      else
        @done = true
      end
      @var = line.chomp!
      temp = Array.new
      if !(line.start_with? "S")
        #Ref: 13
        temp.push(@var.split("|").collect(&:strip))
        arr = Array.new (temp.at(0).drop(1))
        @S = Matrix.rows(@S.to_a << arr)
      end
    end
    status = -1 if (@S.row_count != @Q.length || @S.column_count != @E.length)
    printf "\nERROR: Number of transition table rows does not match with number of states (Q)\n\n" if @S.row_count != @Q.length
    printf "\nERROR: Number of transition table cols does not match with number of tape alphabets (E)\n\n" if @S.column_count != @E.length
    return status
  end

  ######################################################
  #
  # Method: readMachine
  # Description: Validate and initilialize the TM params
  # @input: File containing machine description
  #
  ######################################################
  def readMachine machineFile
    @machineFile = machineFile
    status = 0
    @F, @Q, @I, @E = nil
    # Open the file
    fh = File.open(@machineFile, "r")
    fh.each_line do |line|
      next if line.empty?
      next if line.start_with? "#"

      # Read the machine type to be DFA
      if line.start_with? "Machine"
        var = line.chomp!
        @machineType = var.partition("=").at(2)
      end
      # Extract the set of states from the input file
      if  line.start_with? "Q"
        var = line.chomp!
        # Ref 12
        @Q = var.partition("=").at(2).split(",").collect(&:strip)
      end

      # Extract the set of alphabets from the input file
      if  line.start_with? "E"
        var = line.chomp!
        @E = var.partition("=").at(2).split(",").collect(&:strip)
        @E.insert(0,"B")
      end

      # Extract the set of final states from the input file
      if  line.start_with? "F"
        if (@machineType == "LanguageAcceptor")
          var = line.chomp!
          @F = var.partition("=").at(2).split(",").collect(&:strip)
        end
      end

      # Extract the set of initial states from the input file
      if  line.start_with? "I"
        var = line.chomp!
        @I = var.partition("=").at(2).split(",").collect(&:strip)
      end
    end

    status = -1 if (!@Q || !@I || !@E)
    printf "\nThe Q vector (set of states) is empty\n\n" if !@Q
    printf "\nThe E vector (set of input alphabets and markers) is empty\n\n" if !@E
    printf "\nNo initial state I provided\n\n" if !@I
    printf "\n\nNo final state F provided for Language Acceptor\n" if (!@F && @machineType == "LanguageAcceptor")
    return status
  end

  ######################################################
  #
  # Method: printConsole
  # Description: Prints the current computation, state,
  #              tape head and the tape of TM
  #
  # @input: current index of tape head, current state
  #
  ######################################################
  def printConsole idx, curr_state
    lines_count = 3
    puts " Tape:\t#{@inputString}"#, @inputString
    puts "\e[0J\t#{" " * idx}^"
    puts "\e[0J Head> #{" " * (idx)}#{"["}#{curr_state}#{"]"}"
    sleep(0.2)
    $stdout.flush
    lines_count.times do
      print "\e[1F"
      print "\e[1K"
    end
    print "\033[3A"
    print "\e[3E"
  end

  ######################################################
  #
  # Method: Simulate (inputString)
  # Description: Determines the type of TM and invokes its
  #              simulator on the input string.
  # @input: inputString
  #
  ######################################################
  def Simulate (inputString)
    if (@machineType == "standard")
      print "\n\n==== Simulating the Standard Turing Machine on input string: #{inputString} ====\n\n"
      standardTMsimulate(inputString)
    end

    if (@machineType == "LanguageAcceptor")
      print "\n\n==== Simulating the Language Acceptor Turing Machine on input string: #{inputString} ==== \n\n"
      LanguageAcceptorTMsimulate(inputString)
    end
  end

  ######################################################
  #
  # Method: LanguageAcceptorTMsimulate (inputString)
  # Description: Simulator for a Language Acceptor TM
  # @input: inputString
  #
  ######################################################
  def LanguageAcceptorTMsimulate (inputString)
    status = 0 # Normal
    @inputString =  "B" + inputString + "B" * 2
     curr_state = String.new @I.at(0)
     done = false
     idx = 0

     printConsole(idx, curr_state)
     while (!done)
      char = @inputString[idx]
      row = @Q.find_index(curr_state)
      column = @E.find_index(char)
      if (column != nil)
        transition = Array.new()
        transition.push (@S.element(row,column).split(",").collect(&:strip))
        transition = transition[0]
        # Separate Out the next transition
        (0..transition.length()-1).each do |i|
          status = -10 if transition[i] == "nil"
        end
        if (status == 0)
          curr_state = transition[0]
          @inputString[idx] = transition[1]
          case transition[2]
          when "L"
            idx -= 1
          when "R"
            idx += 1
          else
            $stderr.puts "\n\n\n\n\n==== ERROR: Only L or R allowed in transition table ====\n==== STOP! ===="
          end
        else
          done = true
        end
      else
        $stderr.puts "\n\n\n\n\n==== ERROR: The input string %s is INVALID ====\n==== STOP! ====",
                      @inputString
        return
      end
      if (status != 0 || idx < 0 || idx >= @inputString.length())
        done = true
        if (idx < 0 || idx >= @inputString.length())
          status = -1
        end

        if (status == -10)
          status = 1 if @F.find_index(curr_state) != nil
        end
      else
        printConsole(idx, curr_state)
      end
    end
    if (status == 1)
      sleep(0.3)
      printf "\n\n\n\n==== RESULTS: The string is ACCEPTED by the L(TM) ====\n\n"
    else
      sleep(0.3)
      printf "\n\n\n\n==== RESULTS: The string is NOT ACCEPTED by the L(TM) ====\n\n"
    end
  end

  ######################################################
  #
  # Method: standardTMsimulate
  # Description: Simulator for a standard TM
  # @input: inputString
  #
  ######################################################
  def standardTMsimulate (inputString)
    status = 0 # Normal
    @inputString =  "B" + inputString + "B" * 2
     curr_state = String.new @I.at(0)
     done = false
     idx = 0
     printConsole(idx, curr_state)
     while (!done)
      char = @inputString[idx]
      row = @Q.find_index(curr_state)
      column = @E.find_index(char)
      if (column != nil)
        transition = Array.new()
        transition.push (@S.element(row,column).split(",").collect(&:strip))
        transition = transition[0]
        # Separate Out the next transition
        (0..transition.length()-1).each do |i|
          status = -10 if transition[i] == "nil"
        end
        if (status == 0)
          curr_state = transition[0]
          @inputString[idx] = transition[1]
          case transition[2]
          when "L"
            idx -= 1
          when "R"
            idx += 1
          else
            $stderr.puts "\n\n\n\n==== ERROR: Only L or R allowed in transition table ====\n==== STOP! ===="
          end
        else
          done = true
        end
      else
        $stderr.puts "\n\n\n\n==== ERROR: The input string %s is INVALID ====\n==== STOP! ====",
                      @inputString
        return
      end
      if (status != 0 || idx < 0 || idx >= @inputString.length())
        done = true
        status = 1
        if (idx < 0)
          status = -1
        end
        if (idx >= @inputString.length())
          status = -2
        end
      else
        printConsole(idx, curr_state)
      end
    end
    sleep(0.3)
    printf "\n\n\n\n==== SUCCESS: Turing Machine halted normally ====\n\n" if (status == 1)
    printf "\n\n\n\n==== FAILURE: Turing Machine halted abnormally ====\n\n" if (status == -1)
    printf "\n\n\n\n==== FAILURE: Turing Machine does not halt and overflows the tape ====\n\n" if (status == -2)
  end
end
