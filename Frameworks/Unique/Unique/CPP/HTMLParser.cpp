//
//  HTMLParser.cpp
//  Unique
//
//  Created by Ashwin Paudel on 2022-02-02.
//

#include "HTMLParser.hpp"

char HTMLParser::nextCharacter() {
    return this->source[this->index + 1];
}

bool HTMLParser::startsWith(std::string &string) {
    return this->source.find(string, this->index);
}

bool HTMLParser::isEOF() {
    return this->index >= this->source.length();
}

char HTMLParser::advance() {
    char oldCharacter = this->current;
    this->index++;
    this->current = this->source[this->index];
    return oldCharacter;
}

void HTMLParser::whitespace() {
    if (this->current == ' ' || this->current == '\n' || this->current == '\t' || this->current == '\r')
        while (this->current == ' ' || this->current == '\n' || this->current == '\t' || this->current == '\r')
            this->advance();
}

std::string HTMLParser::getWord() {
    std::string tagName;
    
    while (isalnum(this->current)) {
        tagName.push_back(this->advance());
    }
    
    return tagName;
}

DOMNode HTMLParser::parseNode() {
    this->whitespace();
    
    if (this->current == '<')
        return this->parseElementNode();
    
    return parseTextNode();
}

TextNode HTMLParser::parseTextNode() {
    std::string text = this->getWord();
    
    return TextNode(text);
}

ElementNode HTMLParser::parseElementNode() {
    assert(advance() == '<');
    
    std::string teroBau = "Tero Bau";
    Attributes attributes;
    return ElementNode(teroBau, attributes);
}

void testParser() {
    std::string htmlString = "< yo";
    HTMLParser parser(htmlString.c_str());
    
    while (!parser.isEOF())
        std::cout << parser.parseNode().print() << std::endl;
}
