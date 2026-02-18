classdef Computer < handle
    properties
        originalState (:,1) string
        program (1,1) string
        registerA = nan
        registerB = nan
        registerC = nan

        instructions (:,1) double
        instructionSize
        instructionPointer = 1
        opcode = []
        operand = []
        bSkipJump = false

        output = []
    end


    methods
        function self = Computer(state)
            self.originalState = state;
            self.parseState();
        end


        function reset(self)
            self.instructionPointer = 1;
            self.opcode = [];
            self.operand = [];
            self.bSkipJump = false;
            self.output = [];

            self.parseState();
        end


        function output = run(self)
            funcs = ["adv", "bxl", "bst", "jnz", "bxc", "out", "bdv", "cdv"];
            while self.instructionPointer <= self.instructionSize
                self.opcode = self.instructions(self.instructionPointer);

                if self.instructionPointer + 1 <= self.instructionSize
                    self.operand = self.instructions(self.instructionPointer + 1);
                else
                    self.operand = nan;
                end

                self.(funcs(self.opcode + 1));

                if ~self.bSkipJump
                    self.instructionPointer = self.instructionPointer + 2;
                else
                    self.bSkipJump = false;
                end
            end

            output = self.output;
        end


        function minValueRegisterA = findRegisterAValue(self)
            requiredOutput = str2double(split(self.program, ","));
            trialValue = 1;
            while true
                if self.tryRegisterAValue(trialValue, requiredOutput)
                    break
                end

                trialValue = trialValue + 1;
            end

            minValueRegisterA = trialValue;
        end


        function bSuccess =  tryRegisterAValue(self, trialValue, requiredOutput)
            bSuccess = false;
            self.reset();
            self.registerA = trialValue;
            
            iOutput = 0;
            funcs = ["adv", "bxl", "bst", "jnz", "bxc", "out", "bdv", "cdv"];
            while self.instructionPointer <= self.instructionSize
                self.opcode = self.instructions(self.instructionPointer);

                if self.instructionPointer + 1 <= self.instructionSize
                    self.operand = self.instructions(self.instructionPointer + 1);
                else
                    self.operand = nan;
                end

                thisFunc = funcs(self.opcode + 1);
                self.(thisFunc);

                if ~self.bSkipJump
                    self.instructionPointer = self.instructionPointer + 2;
                else
                    self.bSkipJump = false;
                end

                if thisFunc == "out"
                    iOutput = iOutput + 1;
                    if self.output(iOutput) ~= requiredOutput(iOutput)
                        return
                    end
                end
            end

            trialOutput = self.output;
            if isequal(trialOutput(:), requiredOutput(:))
                bSuccess = true;
            end
        end
    end

    methods (Access = private)
        function parseState(self)
            for ii = 1:height(self.originalState)
                thisLine = self.originalState(ii);

                if contains(thisLine, "Register")
                    registerLetter = extractBetween(thisLine, "Register ", ":");
                    self.("register" + registerLetter) = str2double(extractAfter(thisLine, ":"));
                end

                if contains(thisLine, "Program")
                    self.program = extractAfter(thisLine, ":");
                    self.instructions = str2double(split(self.program, ","));
                    self.instructionSize = numel(self.instructions);
                end
            end
        end


        function comboOperand = combo(self)
            comboOperand = self.operand;

            if self.operand <= 3
                return
            end

            switch self.operand
                case 4
                    comboOperand = self.registerA;
                case 5
                    comboOperand = self.registerB;
                case 6
                    comboOperand = self.registerC;
            end
        end


        function adv(self)
            numerator = self.registerA;
            demominator = 2^self.combo();

            self.registerA = floor(numerator / demominator);
        end


        function bxl(self)
            self.registerB = bitxor(self.registerB, self.operand);
        end


        function bst(self)
            self.registerB = mod(self.combo(), 8);
        end


        function jnz(self)
            if self.registerA == 0
                return
            end

            % +1 becaue MATLAB indices start at 1 instead of 0
            self.instructionPointer = self.operand + 1;
            self.bSkipJump = true;
        end


        function bxc(self)
            self.registerB = bitxor(self.registerB, self.registerC);
        end


        function out(self)
            self.output(end+1) = mod(self.combo(), 8);
        end


        function bdv(self)
            numerator = self.registerA;
            demominator = 2^self.combo();

            self.registerB = floor(numerator / demominator);
        end


        function cdv(self)
            numerator = self.registerA;
            demominator = 2^self.combo();

            self.registerC = floor(numerator / demominator);
        end
    end
end