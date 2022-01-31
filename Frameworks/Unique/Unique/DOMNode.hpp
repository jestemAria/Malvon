//
//  DOMNode.hpp
//  Unique
//
//  Created by Ashwin Paudel on 2022-01-31.
//

#ifndef DOMNode_hpp
#define DOMNode_hpp

#include <iostream>
#include <vector>
#include <map>

class DOMNode {
private:
    std::vector<DOMNode> children;

public:
    DOMNode(std::vector<DOMNode> children) : children(children) {};
    DOMNode() {};
};

class DOMTextNode : public DOMNode {
private:
    const std::string text;
    
public:
    DOMTextNode(std::string data) : text(std::move(data)) {};
    DOMTextNode(std::string data, std::vector<DOMNode> children) : DOMNode(children), text(std::move(data)) {};
    
    std::string get_string();
};

class DOMElementNode : public DOMNode {
private:
    const std::string tag;
    const std::map<std::string, std::string> attributes;

public:
    
    DOMElementNode(std::string tag, std::map<std::string, std::string> attributes)
          : tag(std::move(tag)),
            attributes(std::move(attributes)){};
    
    DOMElementNode(std::string tag, std::map<std::string, std::string> attributes, std::vector<DOMNode> children)
          : DOMNode(std::move(children)),
            tag(std::move(tag)),
            attributes(std::move(attributes)){};

    std::string get_tag();
    std::string get_id();
    std::vector<std::string> get_classes();
    std::string get_attribute(const std::string &property);
    std::string get_attribute(const std::string &property, const std::string &value);
};

#endif /* DOMNode_hpp */
