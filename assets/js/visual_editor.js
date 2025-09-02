// Visual Editor Hook for Medium-style WYSIWYG
export const VisualEditor = {
  mounted() {
    this.editor = this.el;
    this.setupEditor();
    this.bindEvents();
  },

  updated() {
    // Maintain cursor position after updates
    this.restoreCursor();
  },

  setupEditor() {
    // Initialize content if empty
    if (this.editor.innerHTML.trim() === '') {
      this.editor.innerHTML = '<p>Start writing your story...</p>';
    }

    // Set up placeholder behavior
    this.setupPlaceholder();
    
    // Focus on first paragraph
    this.focusEditor();
  },

  setupPlaceholder() {
    const placeholder = '<p class="placeholder">Start writing your story...</p>';
    
    if (this.editor.innerHTML.trim() === '' || 
        this.editor.innerHTML.includes('Start writing your story...')) {
      this.editor.innerHTML = placeholder;
      this.editor.classList.add('is-placeholder');
    }
  },

  focusEditor() {
    const firstP = this.editor.querySelector('p');
    if (firstP) {
      this.setCursorToEnd(firstP);
    }
  },

  bindEvents() {
    // Handle content changes
    this.editor.addEventListener('input', (e) => {
      this.handleInput(e);
    });

    // Handle key presses for better UX
    this.editor.addEventListener('keydown', (e) => {
      this.handleKeyDown(e);
    });

    // Handle paste events
    this.editor.addEventListener('paste', (e) => {
      this.handlePaste(e);
    });

    // Handle focus/blur for placeholder
    this.editor.addEventListener('focus', () => {
      if (this.editor.classList.contains('is-placeholder')) {
        this.editor.innerHTML = '<p><br></p>';
        this.editor.classList.remove('is-placeholder');
        this.focusEditor();
      }
    });

    this.editor.addEventListener('blur', () => {
      if (this.editor.textContent.trim() === '') {
        this.setupPlaceholder();
      }
    });

    // Listen for formatting commands
    this.handleEvent("format_text", ({ type, editor_id }) => {
      if (this.editor.id === editor_id) {
        this.formatText(type);
      }
    });
  },

  handleInput(e) {
    this.saveCursor();
    this.convertMarkdownShortcuts();
    this.syncToMarkdown();
    this.updateWordCount();
  },

  handleKeyDown(e) {
    // Handle Enter key for better paragraph breaks
    if (e.key === 'Enter') {
      if (!e.shiftKey) {
        e.preventDefault();
        this.insertParagraph();
      }
    }
    
    // Handle Tab key
    if (e.key === 'Tab') {
      e.preventDefault();
      this.insertText('    '); // 4 spaces for indentation
    }

    // Handle markdown shortcuts
    if (e.ctrlKey || e.metaKey) {
      switch(e.key) {
        case 'b':
          e.preventDefault();
          this.formatText('bold');
          break;
        case 'i':
          e.preventDefault();
          this.formatText('italic');
          break;
        case 'k':
          e.preventDefault();
          this.formatText('link');
          break;
      }
    }
  },

  handlePaste(e) {
    e.preventDefault();
    const text = e.clipboardData.getData('text/plain');
    this.insertText(text);
    setTimeout(() => {
      this.syncToMarkdown();
    }, 10);
  },

  convertMarkdownShortcuts() {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    const textNode = range.startContainer;
    
    if (textNode.nodeType === Node.TEXT_NODE) {
      const text = textNode.textContent;
      const cursorPos = range.startOffset;
      
      // Check for markdown shortcuts at the beginning of lines
      this.checkHeaderShortcuts(textNode, text, cursorPos);
      this.checkListShortcuts(textNode, text, cursorPos);
      this.checkQuoteShortcuts(textNode, text, cursorPos);
    }
  },

  checkHeaderShortcuts(textNode, text, cursorPos) {
    const headerPatterns = [
      { pattern: /^# (.+)/, tag: 'H1' },
      { pattern: /^## (.+)/, tag: 'H2' },
      { pattern: /^### (.+)/, tag: 'H3' }
    ];

    for (let { pattern, tag } of headerPatterns) {
      const match = text.match(pattern);
      if (match && cursorPos > match[0].length) {
        this.replaceWithElement(textNode, match[1], tag);
        break;
      }
    }
  },

  checkListShortcuts(textNode, text, cursorPos) {
    const listPatterns = [
      { pattern: /^- (.+)/, type: 'ul' },
      { pattern: /^\* (.+)/, type: 'ul' },
      { pattern: /^\d+\. (.+)/, type: 'ol' }
    ];

    for (let { pattern, type } of listPatterns) {
      const match = text.match(pattern);
      if (match && cursorPos > match[0].length) {
        this.createList(textNode, match[1], type);
        break;
      }
    }
  },

  checkQuoteShortcuts(textNode, text, cursorPos) {
    const match = text.match(/^> (.+)/);
    if (match && cursorPos > match[0].length) {
      this.replaceWithElement(textNode, match[1], 'BLOCKQUOTE');
    }
  },

  replaceWithElement(textNode, content, tagName) {
    const element = document.createElement(tagName);
    element.textContent = content;
    
    const paragraph = textNode.parentElement;
    paragraph.parentNode.replaceChild(element, paragraph);
    
    this.setCursorToEnd(element);
    this.syncToMarkdown();
  },

  createList(textNode, content, type) {
    const listElement = document.createElement(type === 'ul' ? 'UL' : 'OL');
    const listItem = document.createElement('LI');
    listItem.textContent = content;
    listElement.appendChild(listItem);
    
    const paragraph = textNode.parentElement;
    paragraph.parentNode.replaceChild(listElement, paragraph);
    
    this.setCursorToEnd(listItem);
    this.syncToMarkdown();
  },

  formatText(type) {
    const selection = window.getSelection();
    if (selection.rangeCount === 0) return;

    switch(type) {
      case 'bold':
        document.execCommand('bold');
        break;
      case 'italic':
        document.execCommand('italic');
        break;
      case 'code':
        this.wrapSelection('code');
        break;
      case 'h1':
        this.formatAsHeader('H1');
        break;
      case 'h2':
        this.formatAsHeader('H2');
        break;
      case 'h3':
        this.formatAsHeader('H3');
        break;
      case 'ul':
        this.formatAsList('UL');
        break;
      case 'ol':
        this.formatAsList('OL');
        break;
      case 'quote':
        this.formatAsBlockquote();
        break;
      case 'link':
        this.createLink();
        break;
      case 'codeblock':
        this.createCodeBlock();
        break;
    }
    
    this.syncToMarkdown();
  },

  formatAsHeader(tagName) {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    const element = range.commonAncestorContainer.nodeType === Node.TEXT_NODE 
      ? range.commonAncestorContainer.parentElement 
      : range.commonAncestorContainer;
    
    if (element.tagName === 'P' || element.tagName.startsWith('H')) {
      const header = document.createElement(tagName);
      header.innerHTML = element.innerHTML;
      element.parentNode.replaceChild(header, element);
      this.setCursorToEnd(header);
    }
  },

  formatAsList(listType) {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    const element = range.commonAncestorContainer.nodeType === Node.TEXT_NODE 
      ? range.commonAncestorContainer.parentElement 
      : range.commonAncestorContainer;
    
    if (element.tagName === 'P') {
      const list = document.createElement(listType);
      const listItem = document.createElement('LI');
      listItem.innerHTML = element.innerHTML;
      list.appendChild(listItem);
      element.parentNode.replaceChild(list, element);
      this.setCursorToEnd(listItem);
    }
  },

  formatAsBlockquote() {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    const element = range.commonAncestorContainer.nodeType === Node.TEXT_NODE 
      ? range.commonAncestorContainer.parentElement 
      : range.commonAncestorContainer;
    
    if (element.tagName === 'P') {
      const blockquote = document.createElement('BLOCKQUOTE');
      blockquote.innerHTML = element.innerHTML;
      element.parentNode.replaceChild(blockquote, element);
      this.setCursorToEnd(blockquote);
    }
  },

  createLink() {
    const selection = window.getSelection();
    const selectedText = selection.toString();
    const url = prompt('Enter URL:', 'https://');
    
    if (url && url !== 'https://') {
      if (selectedText) {
        const link = document.createElement('a');
        link.href = url;
        link.textContent = selectedText;
        
        const range = selection.getRangeAt(0);
        range.deleteContents();
        range.insertNode(link);
        
        selection.removeAllRanges();
        const newRange = document.createRange();
        newRange.setStartAfter(link);
        selection.addRange(newRange);
      } else {
        const linkText = prompt('Enter link text:');
        if (linkText) {
          const link = document.createElement('a');
          link.href = url;
          link.textContent = linkText;
          this.insertElement(link);
        }
      }
    }
  },

  createCodeBlock() {
    const pre = document.createElement('pre');
    const code = document.createElement('code');
    code.textContent = 'Your code here...';
    pre.appendChild(code);
    
    this.insertElement(pre);
    this.setCursorToEnd(code);
  },

  wrapSelection(tagName) {
    const selection = window.getSelection();
    if (selection.rangeCount === 0) return;
    
    const range = selection.getRangeAt(0);
    const selectedText = selection.toString();
    
    if (selectedText) {
      const element = document.createElement(tagName);
      element.textContent = selectedText;
      
      range.deleteContents();
      range.insertNode(element);
      
      selection.removeAllRanges();
      const newRange = document.createRange();
      newRange.setStartAfter(element);
      selection.addRange(newRange);
    }
  },

  insertElement(element) {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    
    range.insertNode(element);
    
    selection.removeAllRanges();
    const newRange = document.createRange();
    newRange.setStartAfter(element);
    selection.addRange(newRange);
  },

  insertText(text) {
    const selection = window.getSelection();
    const range = selection.getRangeAt(0);
    
    const textNode = document.createTextNode(text);
    range.insertNode(textNode);
    
    selection.removeAllRanges();
    const newRange = document.createRange();
    newRange.setStartAfter(textNode);
    selection.addRange(newRange);
  },

  insertParagraph() {
    const paragraph = document.createElement('p');
    paragraph.innerHTML = '<br>';
    
    this.insertElement(paragraph);
    this.setCursorToEnd(paragraph);
  },

  syncToMarkdown() {
    const markdown = this.htmlToMarkdown(this.editor.innerHTML);
    
    // Update hidden input for form submission
    const hiddenInput = document.querySelector(`#hidden-${this.editor.id.split('-').pop()}`);
    if (hiddenInput) {
      hiddenInput.value = markdown;
    }
    
    // Update hidden textarea to trigger LiveView change event
    const editorId = this.editor.id.split('-').pop();
    const hiddenTextarea = document.querySelector(`#visual-content-${editorId}`);
    if (hiddenTextarea) {
      hiddenTextarea.value = markdown;
      
      // Trigger the change event manually
      const event = new Event('input', { bubbles: true });
      hiddenTextarea.dispatchEvent(event);
    }
  },

  htmlToMarkdown(html) {
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = html;
    
    return this.nodeToMarkdown(tempDiv);
  },

  nodeToMarkdown(node) {
    let result = '';
    
    for (let child of node.childNodes) {
      if (child.nodeType === Node.TEXT_NODE) {
        result += child.textContent;
      } else if (child.nodeType === Node.ELEMENT_NODE) {
        const tagName = child.tagName.toLowerCase();
        const text = child.textContent;
        
        switch (tagName) {
          case 'h1':
            result += `# ${text}\n\n`;
            break;
          case 'h2':
            result += `## ${text}\n\n`;
            break;
          case 'h3':
            result += `### ${text}\n\n`;
            break;
          case 'p':
            if (text.trim() && !child.classList.contains('placeholder')) {
              result += `${this.nodeToMarkdown(child)}\n\n`;
            }
            break;
          case 'strong':
          case 'b':
            result += `**${text}**`;
            break;
          case 'em':
          case 'i':
            result += `*${text}*`;
            break;
          case 'code':
            result += `\`${text}\``;
            break;
          case 'pre':
            result += `\`\`\`\n${text}\n\`\`\`\n\n`;
            break;
          case 'blockquote':
            result += `> ${text}\n\n`;
            break;
          case 'a':
            result += `[${text}](${child.href})`;
            break;
          case 'ul':
            for (let li of child.querySelectorAll('li')) {
              result += `- ${li.textContent}\n`;
            }
            result += '\n';
            break;
          case 'ol':
            let index = 1;
            for (let li of child.querySelectorAll('li')) {
              result += `${index}. ${li.textContent}\n`;
              index++;
            }
            result += '\n';
            break;
          default:
            result += this.nodeToMarkdown(child);
        }
      }
    }
    
    return result.trim();
  },

  setCursorToEnd(element) {
    const range = document.createRange();
    const selection = window.getSelection();
    
    range.selectNodeContents(element);
    range.collapse(false);
    
    selection.removeAllRanges();
    selection.addRange(range);
  },

  saveCursor() {
    const selection = window.getSelection();
    if (selection.rangeCount > 0) {
      this.savedRange = selection.getRangeAt(0);
    }
  },

  restoreCursor() {
    if (this.savedRange) {
      const selection = window.getSelection();
      selection.removeAllRanges();
      selection.addRange(this.savedRange);
    }
  },

  updateWordCount() {
    const text = this.editor.textContent || '';
    const words = text.trim().split(/\s+/).filter(word => word.length > 0);
    const wordCount = words.length;
    const readTime = Math.max(1, Math.ceil(wordCount / 200));
    
    // Update word count display
    const wordCountEl = document.querySelector('.editor-header .text-sm');
    if (wordCountEl) {
      wordCountEl.innerHTML = `${wordCount} words &bull; ${readTime} min read`;
    }
  }
};