//
//  DOMNode.hpp
//  Unique
//
//  Created by Ashwin Paudel on 2022-02-02.
//

#ifndef DOMNode_hpp
#define DOMNode_hpp

#include <iostream>
#include <vector>
#include <map>

typedef std::pair<std::string, std::string> Attribute;
typedef std::vector<Attribute> Attributes;

class DOMNode {
    std::vector<DOMNode> children;
    
public:
    DOMNode() {};
    virtual ~DOMNode() {};
    DOMNode(std::vector<DOMNode> &children) : children(children) {};
    
    virtual std::string print() const {return "DOMNode"; };
};

class TextNode : public DOMNode {
    std::string contents;
    
public:
    TextNode(std::string &contents) : contents(contents) {};
    
    virtual std::string print() const { return "TextNode: " + this->contents; };
};

class ElementNode : public DOMNode {
    std::string tag_name;
    Attributes attributes;
    
public:
    ElementNode(std::string &tag_name, Attributes &attributes) :
    tag_name(tag_name), attributes(attributes) {};
    
    ElementNode(std::string &tag_name, Attributes &attributes, std::vector<DOMNode> &children) :
    tag_name(tag_name), attributes(attributes), DOMNode(children) {};
    
    
    virtual std::string print() const { return "ElementNode: " + this->tag_name; };
};

#endif /* DOMNode_hpp */
