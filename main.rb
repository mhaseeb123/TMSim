# Date: 11/30/2017
# Class: CS-5800 | Fall-2017
# Project: Turing Machine Simulator
# Author: Muhammad Haseeb

require 'pp'
require 'matrix'
require './TM_Simulator.rb'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.on("-t", "--[no-]template", "Fetch a template file") do |t|
    options[:template] = t
  end
end.parse!

printf "\n ############ TURING MACHINE Simulator Software ##############\n"
printf " #                                                           #\n"
printf " # Muhammad Haseeb                                           #\n"
printf " # PhD student, Computer_Science                             #\n"
printf " # Western Michigan University                               #\n"
printf " # CS-5800: Theory Foundations - Fall 2017                   #\n"
printf " #                                                           #\n"
printf " #############################################################\n\n"

# Check if template file required
if (options.length() > 0 && options == {:template=>true})
  File.open "templateTM.txt", "w" do |f|
    f.write("# Auto-generated template for Turing Machine\n")
    time1 = Time.new
    f.write("# Generated at: #{time1.inspect} #{time1.zone}\n\n")

    f.write("# Turing Machine Configuration\n")
    f.write("# options: standard, LanguageAcceptor\n")
    f.write("Machine=standard\n\n")

    f.write("# Set of States and Markers separated by comma\n")
    f.write("Q=q0,q1,q2\n\n")

    f.write("# Set of Input Alphabets separated by comma\n")
    f.write("E=a,b\n\n")

    f.write("# Initial State\n")
    f.write("I=q0\n\n")

    f.write("# Set of Final states separated by comma\n")
    f.write("# Required for only Language Acceptors. Ignored otherwise\n")
    f.write("F=q2\n\n")

    f.write("# Transition Table\n")
    f.write("# Separated by pipe\n")
    f.write("S|B|a|b\n")
    f.write("q0|q1,B,R|nil,nil,nil|nil,nil,nil\n")
    f.write("q1|q2,B,L|q1,b,R|q1,a,R\n")
    f.write("q2|nil,nil,nil|q2,a,L|q2,b,L\n")
    f.close()
  end
  printf " TM_Simulator: Generated a template Turing Machine file \"templateTM.txt\" \n\n"
  printf "======= Thanks for using this software =======\n"
  exit(0)
end

# variable for main loop
done = false

# Main loop
while (done == false)
  printf "\n============== Main Menu ===============\n"
  printf "\n1. Initialize a new Turing Machine\n"
  printf "2. Exit\n"
  printf "/> "
  what = gets
  what = what.chomp!.to_i

  # Invalid input
  next if (what != 1 && what != 2)

  # Exit the simulator program if required
  if (what == 2)
    printf "\n======= Thanks for using this software =======\n"
    exit(0)
  end

  # Initialize a new Turing Machine
  while (what == 1)
    printf "\n\nEnter the relative or absolute path to TM input file OR -1 to back to main menu\n\n"
    printf "Note: Only use the forward slashes. example: ./path/to/TM_file.txt\n\n"
    printf "/> "
    path = gets
    path = path.chomp!

    # See if return to main menu
     break if path == "-1"

    # Initialize the TM with the path provided
    @TM_handle = TuringMachine.new path

    # Loop if the file has been parsed successfully
    dec = true
    printf "\nThe Turing Machine initialized successfully..!\n\n" if @TM_handle.valid_machine == true
    while (@TM_handle.valid_machine == true && (dec == true))
      # Get the tape string
      print "\nEnter the string for tape (T): /> "
      string = gets.chomp!

      # Get the number of blanks to be appended at the end of string
      printf "\nNumber of extra blanks \"B\"s to append at end of string /> "
      bs = gets.chomp!.to_i
      bs = string.length() if (bs == 0)

      # Simulate on the composite string
      @TM_handle.Simulate(string + "B" * (string.length() + bs))

      # See if we need to simulate the same Turing machine on another string input
      inp = ""
      while (inp != "yes" && inp != "no" && inp != "Y" && inp != "N" && inp != "y" && inp != "n" && inp != "Yes" && inp != "No" && inp != "YES" && inp != "NO")
        print "\nDo you want to enter another string for the same Turing Machine? Y/N? /> "
        inp = gets.chomp!
      end

      # Return to main menu if we are done with this Turing Machine
      if (inp == "no" || inp == "No" || inp == "N" || inp == "n" || inp == "NO")
        dec = false
        what = 0
        printf "\n\n"
      end
    end
  end
end
printf "\n======= Thanks for using the software =======\n"
