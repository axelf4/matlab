classdef KDNode < handle
    % Node in a KD-tree, K = 2.
    
    properties
        Coord
        Data
    end
    properties (Access = private)
        Index = 1 % 1 or 2 for horizontal or vertical split respectively
        Left = KDNode.empty
        Right = KDNode.empty
    end
    methods
        function obj = KDNode(coord, data)
            obj.Coord = coord;
            obj.Data = data;
        end
        
        function insert(self, new)
            % Inserts the given node into this subtree.
            
            % Flip the index
            if self.Index == 1, new.Index = 2; else, new.Index = 1; end
            
            if new.Coord(self.Index) < self.Coord(self.Index)
                if isempty(self.Left), self.Left = new; else, self.Left.insert(new); end
            else
                if isempty(self.Right), self.Right = new; else, self.Right.insert(new); end
            end
        end
        
        function a = find(self, c, d, filter)
            % Returns a cell array with all subnodes (and self) that
            % satisfy the filter.
            % Only subnodes inside the bounding box centered at c with sides 2*d
            % are considered.
            
            % If node satisfies the filter
            if filter(self.Coord, c), a = {self}; else, a = {}; end
            
            x = self.Coord(self.Index);
            % Add left subtree
            if ~isempty(self.Left) && x > c(self.Index) - d
                a = [a, self.Left.find(c, d, filter)];
            end
            % Add right subtree
            if ~isempty(self.Right) && x <= c(self.Index) + d
                a = [a, self.Right.find(c, d, filter)];
            end
        end
        
        function b = exists(self, c, d, filter)
            % Returns whether there exists a node in this subtree that satisfies the filter.
            % Only subnodes inside the bounding box centered at c with sides 2*d
            % are considered.
            
            x = self.Coord(self.Index);
            % Test self last since later points are likelier to lie closer
            b = ... % If in left subtree
                (~isempty(self.Left) && x > c(self.Index) - d ...
                && self.Left.exists(c, d, filter)) ...
                ... % If in right subtree
                || (~isempty(self.Right) && x <= c(self.Index) + d ...
                && self.Right.exists(c, d, filter)) ...
                || filter(self); % If this node satisfies
        end
        
        function a = findAll(self)
            a = {self};
            if ~isempty(self.Left)
                a = [a, self.Left.findAll()];
            end
            
            if ~isempty(self.Right)
                a = [a, self.Right.findAll()];
            end
        end
    end
end