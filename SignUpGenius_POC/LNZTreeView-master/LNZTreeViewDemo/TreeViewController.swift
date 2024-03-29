//
//  ViewController.swift
//  LNZTreeViewDemo
//
//  Created by Giuseppe Lanza on 07/11/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import UIKit
import LNZTreeView

class CustomUITableViewCell: UITableViewCell
{
    override func layoutSubviews() {
        super.layoutSubviews();
        
        guard var imageFrame = imageView?.frame else { return }
        
        let offset = CGFloat(indentationLevel) * indentationWidth
        imageFrame.origin.x += offset
        imageView?.frame = imageFrame
    }
}


class Node: NSObject, TreeNodeProtocol {
    var display: String
    var identifier: String
    var isExpandable: Bool {
        return children != nil
    }
    
    var children: [Node]?
    
    init(withIdentifier identifier: String, andChildren children: [Node]? = nil, withDisplay display: String) {
        self.display = display
        self.identifier = identifier
        self.children = children
    }
}

class TreeViewController: UIViewController {
    
    @IBOutlet weak var treeView: LNZTreeView!
    var root = [Node]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        treeView.register(CustomUITableViewCell.self, forCellReuseIdentifier: "cell")

        treeView.tableViewRowAnimation = .right
        
        generateRandomNodes()
        treeView.resetTree()
    }
    
    func generateRandomNodes() {
        let depth = 3
        let rootSize = 30
        
        var root: [Node]!
        
        var lastLevelNodes: [Node]?
        
        let dict = ["Fruit":["Carrots","Apple","Bananas",],"Cars":["Jeep","BMW","Pinto"]]
        
            let keys = Array(dict.keys).sorted()
            root = rootNodes(dictionaryKeys: keys)
            lastLevelNodes = root!
        
            var thisDepthLevelNodes = [Node]()
            for node in root {
                
                let values = dict[node.display]!.sorted()
                let children = childNodes(dictionaryValues: values)
                node.children = children
                thisDepthLevelNodes += children
            }
            
            lastLevelNodes = thisDepthLevelNodes
       //}
        self.root = root
    }
    
    func rootNodes(dictionaryKeys: [Any] ) -> [Node] {
        let nodes = Array(dictionaryKeys).map { i -> Node in
            return Node(withIdentifier: "\(arc4random()%UInt32.max)", withDisplay: "\(i)")
        }
        
        return nodes
    }
    
    func childNodes(dictionaryValues: [Any] ) -> [Node] {
        let nodes = Array(dictionaryValues).map { i -> Node in
            return Node(withIdentifier: "\(arc4random()%UInt32.max)", withDisplay: "\(i)" )
        }
        
        return nodes
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: LNZTreeViewDataSource {
    func numberOfSections(in treeView: LNZTreeView) -> Int {
        return 1
    }
    
    func treeView(_ treeView: LNZTreeView, numberOfRowsInSection section: Int, forParentNode parentNode: TreeNodeProtocol?) -> Int {
        guard let parent = parentNode as? Node else {
            return root.count
        }
        
        return parent.children?.count ?? 0
    }
    
    func treeView(_ treeView: LNZTreeView, nodeForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> TreeNodeProtocol {
        guard let parent = parentNode as? Node else {
            return root[indexPath.row]
        }

        return parent.children![indexPath.row]
    }
    
    func treeView(_ treeView: LNZTreeView, cellForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?, isExpanded: Bool) -> UITableViewCell {
        
        let node: Node
        if let parent = parentNode as? Node {
            node = parent.children![indexPath.row]
        } else {
            node = root[indexPath.row]
        }
        
        let cell = treeView.dequeueReusableCell(withIdentifier: "cell", for: node, inSection: indexPath.section)

        if node.isExpandable {
            if isExpanded {
                cell.imageView?.image = #imageLiteral(resourceName: "index_folder_indicator_open")
            } else {
                cell.imageView?.image = #imageLiteral(resourceName: "index_folder_indicator")
            }
        } else {
            cell.imageView?.image = nil
        }
        
        cell.textLabel?.text = node.display
        
        return cell
    }
}

extension ViewController: LNZTreeViewDelegate {
    func treeView(_ treeView: LNZTreeView, heightForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> CGFloat {
        return 60
    }
}
