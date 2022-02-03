//
//  HTMLParser.hpp
//  Unique
//
//  Created by Ashwin Paudel on 2022-02-02.
//

#ifndef HTMLParser_hpp
#define HTMLParser_hpp

#include <iostream>
#include "DOMNode.hpp"

class HTMLParser {
    uint index;
    std::string source;
    char current;
    
public:
    HTMLParser(std::string &source) : source(source) {
        this->index = 0;
        this->current = this->source[this->index];
    }
    
    HTMLParser(std::string source) : source(source) {
        this->index = 0;
        this->current = this->source[this->index];
    }
    
    char nextCharacter();
    bool startsWith(std::string &string);
    bool isEOF();
    char advance();
    void whitespace();
    std::string getWord();
    
    DOMNode parseNode();
    TextNode parseTextNode();
    ElementNode parseElementNode();
};

void testParser();

#endif /* HTMLParser_hpp */
