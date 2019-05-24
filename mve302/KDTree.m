classdef KDTree < handle
    % Wrapper around a KD-tree node.
    
    properties (Access = private)
        Node = KDNode.empty
    end
    methods
        function obj = KDTree()
        end
        
        function insert(self, c, data)
            if isempty(self.Node)
                self.Node = KDNode(c, data);
            else
                self.Node.insert(KDNode(c, data));
            end
        end
        
        function a = find(self, c, d, filter)
            if ~isempty(self.Node)
                a = self.Node.find(c, d, filter);
            else
                a = {};
            end
        end
        
        function a = findAll(self)
            if ~isempty(self.Node)
                a = self.Node.findAll();
            else
                a = {};
            end
        end
    end
end