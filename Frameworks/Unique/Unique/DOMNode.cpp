//
//  DOMNode.cpp
//  Unique
//
//  Created by Ashwin Paudel on 2022-01-31.
//

#include "DOMNode.hpp"

//
// MARK: - DOM Text Node
//
std::string DOMTextNode::get_string() {
    return this->text;
}

//
// MARK: - DOM Element Node
//
std::string DOMElementNode::get_tag() {
    return this->tag;
}

std::string DOMElementNode::get_id() {
    return "test";
}

std::vector<std::string> DOMElementNode::get_classes() {
    return {"test", "test"};
}

std::string DOMElementNode::get_attribute(const std::string &property) {
    return "test";
}

std::string DOMElementNode::get_attribute(const std::string &property, const std::string &value) {
    return "test";
}
