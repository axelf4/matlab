classdef GridNode
    properties
        Coord
        Data
    end
    methods
        function obj = GridNode(coord, data)
            obj.Coord = coord;
            obj.Data = data;
        end
        
        function a = get(self, filter)
            if filter(self), a = {self}; else, a = {}; end
            if ~isempty(self.Next), a = [a, self.Next.get(filter)]; end
        end
        
        function b = exists(self, filter)
            b = filter(self) || ~isempty(self.Next) && self.Next.exists(filter);
        end
    end
end