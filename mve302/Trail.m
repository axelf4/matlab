classdef Trail < handle
    properties
        TouchLeft = false
        TouchRight = false
    end
    properties (Access = private)
        Id
        Next = Trail.empty
    end
    methods
        function obj = Trail()
            persistent id
            if isempty(id), id = 0; end
            obj.Id = id;
            id = id + 1;
        end
        function done = addNext(this, next)
            % Next has to be touching this trail
            
            done = false;
            
            if this == next, return, end % Cannot add self to itself
            % Newer trails have to traverse the older ones
            if this.Id > next.Id
                done = next.addNext(this);
                return
            end
            
            if next.TouchLeft, this.TouchLeft = true; end
            if next.TouchRight, this.TouchRight = true; end
            
            if this.TouchLeft && this.TouchRight
                done = true;
            elseif isempty(this.Next)
                this.Next = next;
            else
                done = this.Next.addNext(next);
            end
        end
        
        % The following two functions are only for visualization purposes
        % and may be slow
        
        function y = touchesLeft(self)
            if self.TouchLeft
                y = true;
            elseif isempty(self.Next)
                y = false;
            else
                y = self.Next.touchesLeft();
            end
        end
        function y = touchesRight(self)
            if self.TouchRight
                y = true;
            elseif isempty(self.Next)
                y = false;
            else
                y = self.Next.touchesRight();
            end
        end
    end
end
