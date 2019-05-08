classdef Trail < handle
    properties
        TouchLeft = false
        TouchRight = false
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
            
            % Cannot add itself to itself
            if this == next, return, end
            if this.Id > next.Id
                done = next.addNext(this);
                return
            end
            
            if this.TouchLeft, next.TouchLeft = true; end
            if this.TouchRight, next.TouchRight = true; end
            
            if isempty(this.Next)
                this.Next = next;
            else
                done = this.Next.addNext(next);
            end
            
            if (this.TouchLeft && ~next.TouchLeft) || (this.TouchRight && ~next.TouchRight)
                disp bad
            end
            this.TouchLeft = next.TouchLeft;
            this.TouchRight = next.TouchRight;
            
            if this.TouchLeft && this.TouchRight
                done = true
                return
            end
        end
    end
end
