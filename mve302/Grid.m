classdef Grid < handle
    properties (Access = private)
        CellSize
        Length
        Data
    end
    methods
        function obj = Grid(cellSize, length)
            obj.CellSize = int32(cellSize);
            obj.Length = length;
            sqrdCount = idivide(length, obj.CellSize, 'ceil');
            obj.Data = cell(sqrdCount);
        end
        
        function insert(self, new)
            row = idivide(new.Coord(1), self.CellSize) + 1;
            col = idivide(new.Coord(2), self.CellSize) + 1;
            
            new.Next = self.Data{row, col};
            self.Data{row, col} = new;
        end
        
        function a = find(self, c, filter)
            row = idivide(c(1), self.CellSize, 'round');
            col = idivide(c(2), self.CellSize, 'round');
            a = {};
            len = length(self.Data);
            for i = max(row, 1):min(row + 1, len)
                for j = max(col, 1):min(col + 1, len)
                    if ~isempty(self.Data{i, j})
                        a = [a, self.Data{i, j}.get(filter)];
                    end
                end
            end
        end
        
        function b = exists(self, c, filter)
            row = idivide(c(1), self.CellSize, 'round');
            col = idivide(c(2), self.CellSize, 'round');
            b = false;
            len = length(self.Data);
            for i = max(row, 1):min(row + 1, len)
                for j = max(col, 1):min(col + 1, len)
                    if ~isempty(self.Data{i, j})
                        if self.Data{i, j}.exists(filter)
                            b = true;
                            return
                        end
                    end
                end
            end
        end
    end
end