module AresMUSH
  module FS3Combat
    class ThreadCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress
      
      attr_accessor :threads, :num
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.threads = integer_arg(args.arg1)
        self.num = trim_arg(args.arg2)
      end

      def required_args
        [ self.threads, self.num ]
      end
      
      def handle
        combat = FS3Combat.find_combat_by_number(client, self.num)
        return if !combat
        
        names = []
        
        threads.to_i.times do |i|
          names.concat ["Thread#{i}"]
        end
        
        type = "Thread"
        
        names.each_with_index do |n, i|
          FS3Combat.join_combat(combat, n, type, enactor, client)
        end
      end
    end
  end
end
